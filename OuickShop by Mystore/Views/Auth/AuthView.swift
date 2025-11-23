import SwiftUI

struct AuthView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var currentStep: AuthStep = .welcome
    @State private var phoneNumber: String = ""
    
    enum AuthStep {
        case welcome
        case phoneAuth
        case otpVerification
        case emailAuth
        case emailSignup
        case profileSetup
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color("bgLight").ignoresSafeArea()
                
                // Content based on current step
                Group {
                    switch currentStep {
                    case .welcome:
                        WelcomeView(onAuthMethodSelected: { method in
                            withAnimation(.easeInOut) {
                                currentStep = method == .phone ? .phoneAuth : .emailAuth
                            }
                        })
                        
                    case .phoneAuth:
                        PhoneAuthView(
                            onContinue: { number in
                                phoneNumber = number
                                withAnimation(.easeInOut) {
                                    currentStep = .otpVerification
                                }
                            },
                            onBack: {
                                withAnimation(.easeInOut) {
                                    currentStep = .welcome
                                }
                            }
                        )
                        
                    case .otpVerification:
                        OTPVerificationView(
                            phoneNumber: phoneNumber,
                            onVerified: { isNewUser in
                                withAnimation(.easeInOut) {
                                    if isNewUser {
                                        currentStep = .profileSetup
                                    }
                                    // If existing user, UserViewModel will handle login automatically
                                }
                            },
                            onBack: {
                                withAnimation(.easeInOut) {
                                    currentStep = .phoneAuth
                                }
                            }
                        )
                        
                    case .emailAuth:
                        EmailAuthView(
                            onLoginSuccess: {
                                // Check if user needs profile setup
                                if userViewModel.currentUser?.firstName.isEmpty ?? true {
                                    withAnimation(.easeInOut) {
                                        currentStep = .profileSetup
                                    }
                                }
                                // Otherwise UserViewModel handles login automatically
                            },
                            onSignupRequested: {
                                withAnimation(.easeInOut) {
                                    currentStep = .emailSignup
                                }
                            },
                            onBack: {
                                withAnimation(.easeInOut) {
                                    currentStep = .welcome
                                }
                            }
                        )
                        
                    case .emailSignup:
                        EmailSignupView(
                            onSignupSuccess: { isNewUser in
                                withAnimation(.easeInOut) {
                                    currentStep = .profileSetup
                                }
                            },
                            onBack: {
                                withAnimation(.easeInOut) {
                                    currentStep = .emailAuth
                                }
                            }
                        )
                        
                    case .profileSetup:
                        ProfileSetupView(
                            phoneNumber: phoneNumber,
                            onComplete: {
                                // Profile setup complete - UserViewModel should have updated isLoggedIn
                                print("Profile setup completed")
                            }
                        )
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    let onAuthMethodSelected: (AuthMethod) -> Void
    
    enum AuthMethod {
        case phone, email
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo/App Name Section
            VStack(spacing: 20) {
                // App Logo
                Image("AppIcon-1024")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(20)
                
                VStack(spacing: 8) {
                    Text("QuickShop")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Groceries delivered in minutes")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Auth Options
            VStack(spacing: 16) {
                Text("Get Started")
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.bottom, 20)
                
                // Phone Number Option
                Button(action: {
                    onAuthMethodSelected(.phone)
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color("primaryYellow"))
                        
                        Text("Continue with Phone Number")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Email Option
                Button(action: {
                    onAuthMethodSelected(.email)
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color("primaryYellow"))
                        
                        Text("Continue with Email")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            
            // Terms and Privacy
            Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 24)
                .padding(.bottom, 40)
        }
        .padding()
    }
}

#Preview {
    AuthView()
        .environmentObject(UserViewModel())
} 