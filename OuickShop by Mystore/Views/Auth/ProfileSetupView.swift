import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    let phoneNumber: String
    let email: String
    let onComplete: () -> Void
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Content
            VStack(spacing: 32) {
                // Title Section
                VStack(spacing: 12) {
                    Text("Welcome to QuickShop!")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Let's set up your profile")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Form Section
                VStack(spacing: 20) {
                    // First Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Enter your first name", text: $firstName)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .font(.system(size: 16))
                            .focused($focusedField, equals: .firstName)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        focusedField == .firstName ? Color("primaryYellow") : Color.gray.opacity(0.3),
                                        lineWidth: focusedField == .firstName ? 2 : 1
                                    )
                            )
                    }
                    
                    // Last Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Enter your last name", text: $lastName)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .font(.system(size: 16))
                            .focused($focusedField, equals: .lastName)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        focusedField == .lastName ? Color("primaryYellow") : Color.gray.opacity(0.3),
                                        lineWidth: focusedField == .lastName ? 2 : 1
                                    )
                            )
                    }
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            
                            // Show Firebase setup instructions if it's a permission error
                            if errorMessage.contains("Firebase") || errorMessage.contains("permission") {
                                Text("📝 Update Firebase Firestore Rules:")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                                    .padding(.top, 4)
                                
                                Text("1. Go to Firebase Console\n2. Select Firestore Database\n3. Update Security Rules\n\nSee FIREBASE_RULES_SETUP.md")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 4)
                            }
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                
                // Continue Button
                Button(action: handleContinue) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Text("Complete Setup")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isFormValid 
                            ? Color("primaryYellow") 
                            : Color.gray.opacity(0.4)
                    )
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || isLoading)
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Skip option (optional)
            Button(action: {
                // Create a minimal profile when skipping
                print("⏭️ Skipping profile setup - creating minimal profile")
                isLoading = true
                errorMessage = nil
                
                // Create minimal profile with "User" as first name
                userViewModel.updateProfile(
                    firstName: "User",
                    lastName: "",
                    email: email
                ) { success in
                    DispatchQueue.main.async {
                        isLoading = false
                        if success {
                            print("✅ Minimal profile created successfully, completing setup")
                            onComplete()
                        } else {
                            print("❌ Failed to create minimal profile")
                            errorMessage = "Failed to skip setup. Please try again."
                        }
                    }
                }
            }) {
                Text("Skip for now")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 40)
            .disabled(isLoading)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .firstName
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    // Previous button
                    if focusedField == .lastName {
                        Button("Previous") {
                            focusedField = .firstName
                        }
                        .foregroundColor(Color("primaryYellow"))
                    }
                    
                    Spacer()
                    
                    // Next/Done button
                    if focusedField == .firstName {
                        Button("Next") {
                            focusedField = .lastName
                        }
                        .foregroundColor(Color("primaryYellow"))
                    } else {
                        Button("Done") {
                            focusedField = nil
                        }
                        .foregroundColor(Color("primaryYellow"))
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func handleContinue() {
        // Dismiss keyboard
        focusedField = nil
        
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate first name is required
        guard !trimmedFirstName.isEmpty else {
            errorMessage = "Please enter your first name"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        // Update user profile with names
        userViewModel.updateProfile(
            firstName: trimmedFirstName, 
            lastName: trimmedLastName, 
            email: email
        ) { success in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    print("✅ Profile setup completed successfully")
                    print("   isLoggedIn: \(self.userViewModel.isLoggedIn)")
                    print("   currentUser: \(self.userViewModel.currentUser?.firstName ?? "nil")")
                    onComplete()
                } else {
                    print("❌ Failed to save profile")
                    errorMessage = "Failed to save profile. Please try again."
                }
            }
        }
    }
}

#Preview {
    ProfileSetupView(
        phoneNumber: "9876543210",
        email: "test@example.com",
        onComplete: { }
    )
    .environmentObject(UserViewModel())
} 