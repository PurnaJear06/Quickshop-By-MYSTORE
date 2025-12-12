import SwiftUI

struct EmailSignupView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    let onSignupSuccess: (Bool) -> Void  // Bool indicates if user is new
    let onBack: () -> Void
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
            
            // Content
            VStack(spacing: 32) {
                // Title Section
                VStack(spacing: 12) {
                    Text("Create your account")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Sign up to get started")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Form Section
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(size: 16))
                            .focused($focusedField, equals: .email)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        focusedField == .email ? Color("primaryYellow") : Color.gray.opacity(0.3),
                                        lineWidth: focusedField == .email ? 2 : 1
                                    )
                            )
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Group {
                                if showPassword {
                                    TextField("Create a password", text: $password)
                                } else {
                                    SecureField("Create a password", text: $password)
                                }
                            }
                            .font(.system(size: 16))
                            .focused($focusedField, equals: .password)
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    focusedField == .password ? Color("primaryYellow") : Color.gray.opacity(0.3),
                                    lineWidth: focusedField == .password ? 2 : 1
                                )
                        )
                        
                        // Password requirements
                        if !password.isEmpty {
                            Text("At least 6 characters")
                                .font(.caption)
                                .foregroundColor(password.count >= 6 ? .green : .gray)
                        }
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Group {
                                if showConfirmPassword {
                                    TextField("Confirm your password", text: $confirmPassword)
                                } else {
                                    SecureField("Confirm your password", text: $confirmPassword)
                                }
                            }
                            .font(.system(size: 16))
                            .focused($focusedField, equals: .confirmPassword)
                            
                            Button(action: {
                                showConfirmPassword.toggle()
                            }) {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    focusedField == .confirmPassword ? Color("primaryYellow") : Color.gray.opacity(0.3),
                                    lineWidth: focusedField == .confirmPassword ? 2 : 1
                                )
                        )
                        
                        // Password match indicator
                        if !confirmPassword.isEmpty && !password.isEmpty {
                            Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                .font(.caption)
                                .foregroundColor(passwordsMatch ? .green : .red)
                        }
                    }
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        HStack {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Sign Up Button
                Button(action: handleSignup) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Text("Create Account")
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
            
            // Sign In Section
            VStack(spacing: 16) {
                // Terms acceptance
                Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Sign In Link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        onBack()
                    }) {
                        Text("Sign In")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("primaryYellow"))
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .email
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    // Previous button
                    if focusedField == .password {
                        Button("Previous") {
                            focusedField = .email
                        }
                        .foregroundColor(Color("primaryYellow"))
                    } else if focusedField == .confirmPassword {
                        Button("Previous") {
                            focusedField = .password
                        }
                        .foregroundColor(Color("primaryYellow"))
                    }
                    
                    Spacer()
                    
                    // Next/Done button
                    if focusedField == .email {
                        Button("Next") {
                            focusedField = .password
                        }
                        .foregroundColor(Color("primaryYellow"))
                    } else if focusedField == .password {
                        Button("Next") {
                            focusedField = .confirmPassword
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
        !email.isEmpty && 
        email.contains("@") && 
        password.count >= 6 && 
        passwordsMatch
    }
    
    private var passwordsMatch: Bool {
        password == confirmPassword && !confirmPassword.isEmpty
    }
    
    private func handleSignup() {
        // Dismiss keyboard
        focusedField = nil
        
        // Validate inputs
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        userViewModel.signUpWithEmail(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    // New user created successfully
                    onSignupSuccess(true)
                } else {
                    errorMessage = error ?? "Failed to create account. Please try again."
                }
            }
        }
    }
}

#Preview {
    EmailSignupView(
        onSignupSuccess: { _ in },
        onBack: { }
    )
    .environmentObject(UserViewModel())
} 