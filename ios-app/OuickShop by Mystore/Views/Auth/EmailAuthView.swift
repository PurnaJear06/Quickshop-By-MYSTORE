import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    let onLoginSuccess: () -> Void
    let onSignupRequested: () -> Void
    let onBack: () -> Void
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showPassword: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
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
                    Text("Welcome back!")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Sign in to your account")
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
                                    TextField("Enter your password", text: $password)
                                } else {
                                    SecureField("Enter your password", text: $password)
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
                
                // Login Button
                Button(action: handleLogin) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Text("Sign In")
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
            
            // Sign Up Section
            VStack(spacing: 16) {
                // Forgot Password
                Button(action: {
                    // Handle forgot password
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("primaryYellow"))
                }
                
                // Sign Up Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        onSignupRequested()
                    }) {
                        Text("Sign Up")
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
                    // Previous/Next buttons
                    if focusedField == .password {
                        Button("Previous") {
                            focusedField = .email
                        }
                        .foregroundColor(Color("primaryYellow"))
                    }
                    
                    Spacer()
                    
                    if focusedField == .email {
                        Button("Next") {
                            focusedField = .password
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
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
    
    private func handleLogin() {
        // Dismiss keyboard
        focusedField = nil
        
        // Validate inputs
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        userViewModel.signInWithEmail(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    print("Email login successful, checking user profile...")
                    // Give time for user data to load before checking profile
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onLoginSuccess()
                    }
                } else {
                    print("Email login failed: \(error ?? "Unknown error")")
                    errorMessage = error ?? "Invalid email or password"
                }
            }
        }
    }
}

#Preview {
    EmailAuthView(
        onLoginSuccess: { },
        onSignupRequested: { },
        onBack: { }
    )
    .environmentObject(UserViewModel())
} 