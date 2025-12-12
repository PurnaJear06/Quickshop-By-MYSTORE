import SwiftUI

struct PhoneAuthView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    let onContinue: (String) -> Void
    let onBack: () -> Void
    
    @State private var phoneNumber: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @FocusState private var isPhoneFieldFocused: Bool
    
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
                    Text("Enter your mobile number")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("We'll send you a verification code")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Phone Input Section
                VStack(spacing: 20) {
                    // Phone input field
                    HStack(spacing: 12) {
                        // Country code
                        HStack(spacing: 8) {
                            Text("🇮🇳")
                                .font(.system(size: 20))
                            Text("+91")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Phone number field
                        TextField("Enter mobile number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .font(.system(size: 16, weight: .medium))
                            .focused($isPhoneFieldFocused)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                
                // Continue Button
                VStack(spacing: 16) {
                    Button(action: handleContinue) {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Text("Send OTP")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            phoneNumber.count >= 10 
                                ? Color("primaryYellow") 
                                : Color.gray.opacity(0.4)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(phoneNumber.count < 10 || isLoading)
                    .padding(.horizontal, 24)
                    
                    // Phone number validation hint
                    if phoneNumber.count > 0 && phoneNumber.count < 10 {
                        Text("Please enter a valid 10-digit mobile number")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Terms
            VStack(spacing: 8) {
                Text("By continuing, you agree to our")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Button("Terms of Service") {
                        // Handle terms tap
                    }
                    .font(.caption)
                    .foregroundColor(Color("primaryYellow"))
                    
                    Text("and")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button("Privacy Policy") {
                        // Handle privacy tap
                    }
                    .font(.caption)
                    .foregroundColor(Color("primaryYellow"))
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPhoneFieldFocused = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isPhoneFieldFocused = false
                    }
                    .foregroundColor(Color("primaryYellow"))
                }
            }
        }
    }
    
    private func handleContinue() {
        // Dismiss keyboard
        isPhoneFieldFocused = false
        
        // Validate phone number
        guard phoneNumber.count == 10, phoneNumber.allSatisfy({ $0.isNumber }) else {
            errorMessage = "Please enter a valid 10-digit mobile number"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        // Send OTP via Firebase with better error handling
        userViewModel.signInWithPhone(phone: "+91\(phoneNumber)") { [self] success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    self.onContinue(phoneNumber)
                } else {
                    let errorMsg = error ?? "Failed to send OTP. Please try again."
                    print("📱 Phone auth failed: \(errorMsg)")
                    
                    // Check for APNs related errors and provide helpful message
                    if errorMsg.contains("APNs") || errorMsg.contains("push") || errorMsg.contains("verification") {
                        self.errorMessage = "Phone verification unavailable. Please try email login or enable notifications in Settings."
                    } else {
                        self.errorMessage = errorMsg
                    }
                }
            }
        }
    }
}

#Preview {
    PhoneAuthView(
        onContinue: { _ in },
        onBack: { }
    )
    .environmentObject(UserViewModel())
} 