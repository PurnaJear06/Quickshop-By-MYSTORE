import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @EnvironmentObject var userViewModel: UserViewModel
    
    // Animation states
    @State private var opacity = 0.0
    @State private var scale = 1.02
    
    var body: some View {
        ZStack {
            if isActive {
                // Show AuthView first instead of MainTabView
                if userViewModel.isLoggedIn {
                    MainTabView()
                        .transition(.opacity.combined(with: .slide))
                } else {
                    AuthView()
                        .transition(.opacity.combined(with: .slide))
                }
            } else {
                // Full screen banner
                GeometryReader { geo in
                    if let _ = UIImage(named: "SplashBanner") {
                        Image("SplashBanner")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .opacity(opacity)
                            .scaleEffect(scale)
                    } else {
                        // Fallback if image is missing
                        ZStack {
                            Color(hex: "FFDC64")
                            
                            Text("QuickShop")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.black)
                                .opacity(opacity)
                                .scaleEffect(scale)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            // Simple fade in animation
            withAnimation(.easeOut(duration: 0.7)) {
                opacity = 1.0
                scale = 1.0
            }
            
            // Transition out after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 0
                    scale = 1.05
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(HomeViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(UserViewModel())
} 