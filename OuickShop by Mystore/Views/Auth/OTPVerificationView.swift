import SwiftUI

struct OTPVerificationView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    let phoneNumber: String
    let onVerified: (Bool) -> Void  // Bool indicates if user is new
    let onBack: () -> Void
    
    @State private var otpCode: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var timeRemaining = 30
    @State private var timer: Timer? = nil
    @FocusState private var isOTPFieldFocused: Bool
    
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
                    Text("Enter verification code")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 4) {
                        Text("We've sent a 6-digit verification code to")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Text("+91 \(phoneNumber)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                // OTP Input Section
                VStack(spacing: 24) {
                    // OTP Fields - Optimized for 6 digits with better spacing
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            otpDigitView(index)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Hidden field for actual input
                    TextField("", text: $otpCode)
                        .keyboardType(.numberPad)
                        .focused($isOTPFieldFocused)
                        .opacity(0)
                        .frame(width: 1, height: 1)
                        .onChange(of: otpCode) { oldValue, newValue in
                            // Limit to 6 digits
                            if newValue.count > 6 {
                                otpCode = String(newValue.prefix(6))
                            }
                            
                            // Auto-submit when 6 digits entered
                            if newValue.count == 6 && !isLoading {
                                verifyOTP()
                            }
                        }
                }
                
                // Verify Button
                Button(action: verifyOTP) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Text("Verify")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        otpCode.count == 6
                            ? Color("primaryYellow")
                            : Color.gray.opacity(0.4)
                    )
                    .cornerRadius(12)
                }
                .disabled(otpCode.count < 6 || isLoading)
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Resend Section
            VStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("Didn't receive the code?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    if timeRemaining > 0 {
                        Text("Resend in \(timeRemaining)s")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("primaryYellow").opacity(0.7))
                    } else {
                        Button(action: resendOTP) {
                            Text("Resend OTP")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("primaryYellow"))
                        }
                    }
                }
                
                // Change number option
                Button(action: {
                    onBack()
                }) {
                    Text("Change phone number")
                        .font(.system(size: 14))
                        .foregroundColor(Color("primaryYellow"))
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            startResendTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isOTPFieldFocused = true
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isOTPFieldFocused = false
                    }
                    .foregroundColor(Color("primaryYellow"))
                }
            }
        }
    }
    
    // OTP digit view - Optimized for 6 digits with better spacing
    private func otpDigitView(_ index: Int) -> some View {
        let digit = index < otpCode.count ? String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]) : ""
        
        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    index == otpCode.count ? Color("primaryYellow") : Color.gray.opacity(0.3), 
                    lineWidth: index == otpCode.count ? 2 : 1
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
                .frame(width: 50, height: 50) // Slightly larger for better usability
            
            if digit.isEmpty {
                // Show cursor for current position
                if index == otpCode.count {
                    Rectangle()
                        .fill(Color("primaryYellow"))
                        .frame(width: 2, height: 22)
                        .opacity(0.8)
                }
            } else {
                Text(digit)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .onTapGesture {
            isOTPFieldFocused = true
        }
    }
    
    private func startResendTimer() {
        timeRemaining = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    private func verifyOTP() {
        guard otpCode.count == 6 else {
            errorMessage = "Please enter all 6 digits of the verification code"
            return
        }
        
        // Validate that all characters are numbers
        guard otpCode.allSatisfy({ $0.isNumber }) else {
            errorMessage = "Verification code should contain only numbers"
            return
        }
        
        errorMessage = nil
        isLoading = true
        isOTPFieldFocused = false
        
        userViewModel.verifyOTP(otp: otpCode) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    print("OTP verification successful")
                    // Wait a bit for user data to load, then check if user needs profile setup
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let isNewUser = userViewModel.currentUser?.firstName.isEmpty ?? true
                        print("Is new user: \(isNewUser)")
                        onVerified(isNewUser)
                    }
                } else {
                    print("OTP verification failed: \(error ?? "Unknown error")")
                    errorMessage = error ?? "Invalid verification code. Please try again."
                    // Clear OTP and refocus
                    otpCode = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isOTPFieldFocused = true
                    }
                }
            }
        }
    }
    
    private func resendOTP() {
        userViewModel.signInWithPhone(phone: "+91\(phoneNumber)") { success, error in
            DispatchQueue.main.async {
                if success {
                    startResendTimer()
                    otpCode = ""
                    isOTPFieldFocused = true
                } else {
                    errorMessage = error ?? "Failed to resend code. Please try again."
                }
            }
        }
    }
}

#Preview {
    OTPVerificationView(
        phoneNumber: "9876543210",
        onVerified: { _ in },
        onBack: { }
    )
    .environmentObject(UserViewModel())
} 