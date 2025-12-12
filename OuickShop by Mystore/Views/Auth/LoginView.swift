import SwiftUI

struct LoginView: View {
    // Environment objects
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        // Simply use our new AuthView
        AuthView()
            .environmentObject(userViewModel)
    }
}

struct EmailLoginView: View {
    // Environment objects
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // State
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @FocusState private var isEmailFieldFocused: Bool
    @FocusState private var isPasswordFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Background
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
                }
                .padding(.horizontal)
                
                // App logo and title
                VStack(spacing: 15) {
                    Image("AppIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Text("QuickShop")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("Login with Email")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Login form
                VStack(spacing: 20) {
                    Text("Enter your credentials")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Email input field
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isEmailFieldFocused)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isEmailFieldFocused = true
                                }
                            }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(Color.white.cornerRadius(10))
                    )
                    
                    // Password input field
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        SecureField("Password", text: $password)
                            .focused($isPasswordFieldFocused)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(Color.white.cornerRadius(10))
                    )
                    
                    // Error message (if any)
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Login Button
                    Button(action: handleLogin) {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Login")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            !email.isEmpty && !password.isEmpty
                                ? Color("primaryBlue") 
                                : Color.gray.opacity(0.5)
                        )
                        .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    

                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Terms and conditions
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isEmailFieldFocused = false
                    isPasswordFieldFocused = false
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    func handleLogin() {
        // Hide keyboard
        isEmailFieldFocused = false
        isPasswordFieldFocused = false
        
        errorMessage = nil
        isLoading = true
        
        // Call UserViewModel to authenticate
        userViewModel.signInWithEmail(email: email, password: password) { success, error in
            isLoading = false
            
            if success {
                // Successfully logged in, dismiss
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = error ?? "Failed to log in"
            }
        }
    }
    

}

#Preview {
    LoginView()
        .environmentObject(UserViewModel())
} 