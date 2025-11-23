import SwiftUI

struct SignUpView: View {
    // Environment objects
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Properties
    let phoneNumber: String
    
    // State
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var registrationComplete: Bool = false
    
    var body: some View {
        ZStack {
            Color("bgLight").ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header with back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Create Account")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal)
                
                // Welcome text
                VStack(spacing: 8) {
                    Text("Welcome to QuickShop!")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Please fill in your details to complete registration")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                // Registration Form
                VStack(spacing: 20) {
                    // Phone number (already verified)
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(Color("primaryBlue"))
                            .frame(width: 24)
                        
                        Text("+91 \(phoneNumber)")
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    
                    // First Name Field
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(Color("primaryBlue"))
                            .frame(width: 24)
                        
                        TextField("First Name", text: $firstName)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    
                    // Last Name Field
                    HStack {
                        Image(systemName: "person.text.rectangle.fill")
                            .foregroundColor(Color("primaryBlue"))
                            .frame(width: 24)
                        
                        TextField("Last Name", text: $lastName)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    
                    // Email Field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color("primaryBlue"))
                            .frame(width: 24)
                        
                        TextField("Email Address", text: $email)
                            .font(.system(size: 16))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Register Button
                Button(action: registerUser) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Complete Registration")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        isFormValid
                            ? Color("primaryBlue")
                            : Color.gray.opacity(0.5)
                    )
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
                }
                .disabled(!isFormValid || isLoading)
                
                // Terms and conditions
                Text("By registering, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $registrationComplete) {
            MainTabView()
                .navigationBarHidden(true)
        }
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return email.isEmpty || emailPred.evaluate(with: email)
    }
    
    private func registerUser() {
        guard isFormValid else {
            errorMessage = "Please provide all required information"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        // Update profile with additional user info
        userViewModel.updateProfile(firstName: firstName, lastName: lastName, email: email) { success in
            isLoading = false
            
            if success {
                registrationComplete = true
            } else {
                errorMessage = "Failed to register. Please try again."
            }
        }
    }
}

#Preview {
    NavigationView {
        SignUpView(phoneNumber: "9876543210")
            .environmentObject(UserViewModel())
    }
} 