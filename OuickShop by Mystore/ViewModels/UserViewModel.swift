import Foundation
import UIKit
import Combine
import FirebaseAuth
import FirebaseFirestore

class UserViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    // Authentication state properties
    @Published var verificationID: String = ""
    @Published var authUser: FirebaseAuth.User?
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check current authentication state
        checkAuthState()
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.authUser = user
                if user != nil {
                    self?.loadUserData()
                } else {
                    self?.signOut()
                }
            }
        }
    }
    
    // MARK: - Authentication State Management
    
    func checkAuthState() {
        isLoading = true
        print("🔍 Checking auth state...")
        
        if let user = Auth.auth().currentUser {
            print("✅ Firebase user found: \(user.uid)")
            self.authUser = user
            loadUserData()
        } else {
            print("❌ No Firebase user found")
            self.isLoggedIn = false
            self.currentUser = nil
            isLoading = false
        }
    }
    
    private func loadUserData() {
        guard let firebaseUser = authUser else {
            print("No Firebase user found")
            isLoading = false
            return
        }
        
        isLoading = true
        print("Loading user data for: \(firebaseUser.uid)")
        
        // Try to load user from Firestore
        db.collection("users").document(firebaseUser.uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading user data: \(error.localizedDescription)")
                    // Still create user document even if there's an error
                    self.createUserDocument(firebaseUser: firebaseUser)
                    self.isLoading = false
                    return
                }
                
                if let document = document, document.exists, let data = document.data() {
                    print("User document found in Firestore")
                    // User exists in Firestore
                    let firstName = data["firstName"] as? String ?? ""
                    let lastName = data["lastName"] as? String ?? ""
                    
                    // Handle legacy name field for backward compatibility
                    let legacyName = data["name"] as? String ?? ""
                    let finalFirstName = firstName.isEmpty && !legacyName.isEmpty ? legacyName.components(separatedBy: " ").first ?? "" : firstName
                    let finalLastName = lastName.isEmpty && !legacyName.isEmpty ? legacyName.components(separatedBy: " ").dropFirst().joined(separator: " ") : lastName
                    
                    self.currentUser = User(
                        id: firebaseUser.uid,
                        firstName: finalFirstName,
                        lastName: finalLastName,
                        email: data["email"] as? String ?? firebaseUser.email ?? "",
                        phone: data["phone"] as? String ?? firebaseUser.phoneNumber ?? "",
                        addresses: [], // Will load addresses separately
                        profileImageURL: data["profileImageURL"] as? String
                    )
                    self.isLoggedIn = true
                    print("User loaded successfully. IsLoggedIn: \(self.isLoggedIn)")
                    self.loadOrders()
                } else {
                    print("User document not found - creating new user")
                    // New user - create user document
                    self.createUserDocument(firebaseUser: firebaseUser)
                }
                
                self.isLoading = false
            }
        }
    }
    
    private func createUserDocument(firebaseUser: FirebaseAuth.User) {
        print("📝 Creating user document for: \(firebaseUser.uid)")
        
        // Split display name if available
        let displayName = firebaseUser.displayName ?? ""
        let nameComponents = displayName.components(separatedBy: " ")
        let firstName = nameComponents.first ?? "User"
        let lastName = nameComponents.count > 1 ? nameComponents.dropFirst().joined(separator: " ") : ""
        
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": firebaseUser.email ?? "",
            "phone": firebaseUser.phoneNumber ?? "",
            "createdAt": Timestamp(),
            "profileImageURL": firebaseUser.photoURL?.absoluteString ?? ""
        ]
        
        db.collection("users").document(firebaseUser.uid).setData(userData) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error creating user document: \(error.localizedDescription)")
                    
                    // Check if it's a permission error
                    if error.localizedDescription.contains("permission") {
                        print("⚠️ FIREBASE PERMISSION ERROR:")
                        print("   Please update Firestore security rules in Firebase Console")
                        print("   See FIREBASE_RULES_SETUP.md for instructions")
                        self.error = "Firebase permissions not configured. Please update Firestore security rules."
                    } else {
                        self.error = "Failed to create user profile: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                } else {
                    print("✅ User document created successfully")
                    self.currentUser = User(
                        id: firebaseUser.uid,
                        firstName: firstName,
                        lastName: lastName,
                        email: firebaseUser.email ?? "",
                        phone: firebaseUser.phoneNumber ?? "",
                        addresses: [],
                        profileImageURL: firebaseUser.photoURL?.absoluteString
                    )
                    // Set login state AFTER currentUser is populated
                    self.isLoggedIn = true
                    print("✅ User logged in. firstName: \(firstName), isLoggedIn: \(self.isLoggedIn)")
                }
            }
        }
    }
    
    // MARK: - Phone Authentication
    
    func signInWithPhone(phone: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        error = nil
        
        print("📱 Attempting to send OTP to: \(phone)")
        
        // Validate phone number format
        guard phone.count >= 10 else {
            print("❌ Phone validation failed - too short")
            DispatchQueue.main.async {
                self.isLoading = false
                completion(false, "Please enter a valid phone number")
            }
            return
        }
        
        // Safety check for main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.signInWithPhone(phone: phone, completion: completion)
            }
            return
        }
        
        // Format phone number with country code if not present
        let formattedPhone = phone.hasPrefix("+") ? phone : "+91\(phone)"
        print("📱 Formatted phone: \(formattedPhone)")
        
        // Check if Firebase is properly configured
        guard let app = Auth.auth().app else {
            print("❌ Firebase app not properly configured")
            DispatchQueue.main.async {
                self.isLoading = false
                completion(false, "Authentication service unavailable. Please restart the app and try again.")
            }
            return
        }
        
        print("✅ Firebase app configured: \(app.name)")
        
        // Check APNs configuration with better error handling
        let apnsConfigured = UIApplication.shared.isRegisteredForRemoteNotifications
        print("📱 APNs registration status: \(apnsConfigured)")
        
        if !apnsConfigured {
            print("⚠️ APNs not configured - attempting to register")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            // Give a moment for registration to process
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.proceedWithPhoneAuth(formattedPhone: formattedPhone, completion: completion)
            }
            return
        }
        
        proceedWithPhoneAuth(formattedPhone: formattedPhone, completion: completion)
    }
    
         private func proceedWithPhoneAuth(formattedPhone: String, completion: @escaping (Bool, String?) -> Void) {
        print("🔥 Proceeding with phone authentication for: \(formattedPhone)")
        
        // Configure Firebase Auth settings based on environment
        #if targetEnvironment(simulator)
        print("📱 Running on simulator - enabling test mode for phone auth")
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #else
        print("📱 Running on real device - production phone auth mode")
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        #endif
        
        // Use PhoneAuthProvider with enhanced error handling
        let phoneAuthProvider = PhoneAuthProvider.provider()
        print("📞 Initiating phone verification for: \(formattedPhone)")
        
        // Add a timeout mechanism with safety checks
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.isLoading {
                    print("⏰ Phone auth request timed out")
                    self.isLoading = false
                    completion(false, "Request timed out. Please check your network connection and try again.")
                }
            }
        }
        
        phoneAuthProvider.verifyPhoneNumber(formattedPhone, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                timeoutTimer.invalidate() // Cancel timeout timer
                
                guard let self = self else { 
                    print("⚠️ Self was deallocated during phone auth")
                    return 
                }
                
                self.isLoading = false
                
                if let error = error {
                    print("❌ Phone auth error: \(error.localizedDescription)")
                    print("🔍 Error details: \(error)")
                    
                    // Handle specific Firebase auth errors
                    let errorMessage: String
                    if let authError = error as NSError? {
                        print("🔍 Error code: \(authError.code), domain: \(authError.domain)")
                        
                        switch authError.code {
                        case 17010: // FIRAuthErrorCodeInvalidPhoneNumber
                            errorMessage = "Invalid phone number format. Please check and try again."
                        case 17999: // FIRAuthErrorCodeAppNotVerified
                            errorMessage = "App verification failed. Please ensure notifications are enabled and try again."
                        case 17028: // FIRAuthErrorCodePhoneAuthDisabled
                            errorMessage = "Phone authentication is disabled. Please use email login."
                        case 17020: // FIRAuthErrorCodeNetworkError
                            errorMessage = "Network error. Please check your connection and try again."
                        case 17051: // FIRAuthErrorCodeMissingAppCredential
                            errorMessage = "App configuration error. Please restart the app and try again."
                        case 17068: // FIRAuthErrorCodeMissingAppToken
                            errorMessage = "Push notifications required for phone authentication. Please enable notifications in Settings and restart the app."
                        case 17999: // FIRAuthErrorCodeAppNotVerified  
                            errorMessage = "App verification failed. This may be due to APNs configuration. Try using email login instead."
                        default:
                            if error.localizedDescription.contains("network") || error.localizedDescription.contains("Network") {
                                errorMessage = "Network error. Please check your internet connection and try again."
                            } else if error.localizedDescription.contains("quota") || error.localizedDescription.contains("Quota") {
                                errorMessage = "SMS quota exceeded. Please try again later or use email login."
                            } else if error.localizedDescription.contains("invalid") || error.localizedDescription.contains("Invalid") {
                                errorMessage = "Invalid phone number format. Please check and try again."
                            } else if error.localizedDescription.contains("APNs") || error.localizedDescription.contains("push") {
                                errorMessage = "Push notification setup required. Please enable notifications in Settings and restart the app."
                            } else if error.localizedDescription.contains("app-verification") {
                                errorMessage = "Unable to verify app. Please ensure you're using the latest version and try again."
                            } else {
                                errorMessage = "Unable to send verification code. Please try email login or contact support."
                            }
                        }
                    } else {
                        errorMessage = "Phone authentication failed. Please try email login."
                    }
                    completion(false, errorMessage)
                    return
                }
                
                if let verificationID = verificationID, !verificationID.isEmpty {
                    print("✅ OTP sent successfully. Verification ID: \(verificationID)")
                    self.verificationID = verificationID
                    completion(true, nil)
                } else {
                    print("❌ No verification ID received - this might indicate a Firebase setup issue")
                    completion(false, "Failed to send verification code. Please ensure notifications are enabled and try again.")
                }
            }
        }
    }
    
    func verifyOTP(otp: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        error = nil
        
        // Safety check for verification ID
        guard !verificationID.isEmpty else {
            print("❌ No verification ID found")
            DispatchQueue.main.async {
                self.isLoading = false
                completion(false, "Verification session expired. Please request a new OTP.")
            }
            return
        }
        
        guard !otp.isEmpty, otp.count == 6 else {
            print("❌ Invalid OTP format")
            DispatchQueue.main.async {
                self.isLoading = false
                completion(false, "Please enter a valid 6-digit verification code.")
            }
            return
        }
        
        print("🔐 Verifying OTP: \(otp) with verification ID: \(verificationID)")
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otp
        )
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("❌ OTP verification failed: \(error.localizedDescription)")
                    
                    // Handle specific OTP errors
                    let errorMessage: String
                    if error.localizedDescription.contains("invalid") {
                        errorMessage = "Invalid verification code. Please check and try again."
                    } else if error.localizedDescription.contains("expired") {
                        errorMessage = "Verification code expired. Please request a new one."
                    } else {
                        errorMessage = "Verification failed. Please try again."
                    }
                    completion(false, errorMessage)
                } else {
                    print("✅ OTP verification successful")
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - Email Authentication
    
    func signInWithEmail(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        error = nil
        
        print("Attempting email sign in for: \(email)")
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("Email sign in failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else {
                    print("Email sign in successful")
                    completion(true, nil)
                }
            }
        }
    }
    
    func signUpWithEmail(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        error = nil
        
        print("Attempting email sign up for: \(email)")
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("Email sign up failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else {
                    print("Email sign up successful")
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isLoggedIn = false
            orders = []
            error = nil
        } catch {
            self.error = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    
    // MARK: - User Profile Management
    
    func updateProfile(firstName: String, lastName: String, email: String, completion: @escaping (Bool) -> Void) {
        guard let firebaseUser = authUser else {
            print("❌ No Firebase user found for profile update")
            completion(false)
            return
        }
        
        // Ensure we have valid first name (fallback to "User" if empty)
        let validFirstName = firstName.isEmpty ? "User" : firstName
        
        let userData: [String: Any] = [
            "firstName": validFirstName,
            "lastName": lastName,
            "email": email,
            "phone": firebaseUser.phoneNumber ?? "",
            "updatedAt": Timestamp()
        ]
        
        print("📝 Updating profile for user: \(firebaseUser.uid)")
        print("   firstName: \(validFirstName), lastName: \(lastName), email: \(email)")
        
        db.collection("users").document(firebaseUser.uid).setData(userData, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error updating profile: \(error.localizedDescription)")
                    
                    // Check if it's a permission error
                    if error.localizedDescription.contains("permission") {
                        print("⚠️ FIREBASE PERMISSION ERROR:")
                        print("   Please update Firestore security rules in Firebase Console")
                        print("   Go to: https://console.firebase.google.com/project/quickshop-f8450/firestore/rules")
                        print("   See FIREBASE_RULES_SETUP.md for detailed instructions")
                        self.error = "Firebase permissions not configured. Please update Firestore security rules in Firebase Console."
                    } else {
                        self.error = "Failed to update profile: \(error.localizedDescription)"
                    }
                    completion(false)
                } else {
                    print("✅ Profile updated successfully in Firestore")
                    
                    // Update local user object FIRST
                    self.currentUser = User(
                        id: firebaseUser.uid,
                        firstName: validFirstName,
                        lastName: lastName,
                        email: email,
                        phone: firebaseUser.phoneNumber ?? "",
                        addresses: self.currentUser?.addresses ?? [],
                        profileImageURL: self.currentUser?.profileImageURL
                    )
                    
                    // THEN set logged in state (ensures currentUser is populated)
                    self.isLoggedIn = true
                    print("✅ User logged in. firstName: \(validFirstName), isLoggedIn: \(self.isLoggedIn)")
                    completion(true)
                }
            }
        }
    }
    
    func addAddress(title: String, fullAddress: String, landmark: String?, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser, let firebaseUser = authUser else {
            completion(false)
            return
        }
        
        let newAddress = Address(
            id: UUID().uuidString,
            title: title,
            fullAddress: fullAddress,
            landmark: landmark,
            isDefault: user.addresses.isEmpty
        )
        
        var addresses = user.addresses
        addresses.append(newAddress)
        
        let addressData = addresses.map { address in
            [
                "id": address.id,
                "title": address.title,
                "fullAddress": address.fullAddress,
                "landmark": address.landmark ?? "",
                "isDefault": address.isDefault
            ]
        }
        
        db.collection("users").document(firebaseUser.uid).updateData([
            "addresses": addressData
        ]) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if error == nil {
                    self.currentUser = User(
                        id: user.id,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        email: user.email,
                        phone: user.phone,
                        addresses: addresses,
                        profileImageURL: user.profileImageURL
                    )
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Orders Management
    
    private func loadOrders() {
        guard let firebaseUser = authUser else { return }
        
        db.collection("orders")
            .whereField("userId", isEqualTo: firebaseUser.uid)
            .order(by: "orderDate", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.error = "Failed to load orders: \(error.localizedDescription)"
                        return
                    }
                    
                    // For now, use sample orders until we implement real orders
                    self.orders = Order.sampleOrders
                }
            }
    }
    
    func getRecentOrders() -> [Order] {
        return orders.sorted(by: { $0.orderDate > $1.orderDate })
    }
} 