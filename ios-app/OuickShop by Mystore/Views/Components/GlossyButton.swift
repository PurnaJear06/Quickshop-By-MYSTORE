import SwiftUI

struct GlossyButton: View {
    let title: String
    let action: () -> Void
    var backgroundColor: Color = Color("primaryRed")
    var foregroundColor: Color = .white
    var isPressed: Bool = false
    var cornerRadius: CGFloat = 8
    var fontSize: CGFloat = 16
    var fontWeight: Font.Weight = .bold
    var horizontalPadding: CGFloat = 20
    var verticalPadding: CGFloat = 12
    var isEnabled: Bool = true
    
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Trigger animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating.toggle()
            }
            
            // Reset animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = false
                }
            }
            
            action()
        }) {
            Text(title)
                .font(.system(size: fontSize, weight: fontWeight))
                .foregroundColor(foregroundColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        // Base background
                        backgroundColor
                            .opacity(isEnabled ? 1.0 : 0.5)
                        
                        // Glossy overlay
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white.opacity(0.4), location: 0.0),
                                .init(color: Color.white.opacity(0.1), location: 0.3),
                                .init(color: Color.clear, location: 0.7),
                                .init(color: Color.black.opacity(0.1), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .cornerRadius(cornerRadius)
                .shadow(
                    color: backgroundColor.opacity(0.3),
                    radius: isAnimating ? 8 : 4,
                    x: 0,
                    y: isAnimating ? 4 : 2
                )
                .scaleEffect(isAnimating || isPressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
}

// MARK: - Convenience Initializers
extension GlossyButton {
    // Primary Button (Red)
    static func primary(
        title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true
    ) -> GlossyButton {
        GlossyButton(
            title: title,
            action: action,
            backgroundColor: Color("primaryRed"),
            isEnabled: isEnabled
        )
    }
    
    // Secondary Button (Green)
    static func secondary(
        title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true
    ) -> GlossyButton {
        GlossyButton(
            title: title,
            action: action,
            backgroundColor: Color.green,
            isEnabled: isEnabled
        )
    }
    
    // Small Button (for product cards)
    static func small(
        title: String,
        action: @escaping () -> Void,
        backgroundColor: Color = Color("primaryRed"),
        isPressed: Bool = false,
        isEnabled: Bool = true
    ) -> GlossyButton {
        GlossyButton(
            title: title,
            action: action,
            backgroundColor: backgroundColor,
            isPressed: isPressed,
            cornerRadius: 6,
            fontSize: 11,
            fontWeight: .bold,
            horizontalPadding: 12,
            verticalPadding: 6,
            isEnabled: isEnabled
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        GlossyButton.primary(title: "Primary Button") {}
        GlossyButton.secondary(title: "Secondary Button") {}
        GlossyButton.small(title: "ADD") {}
    }
    .padding()
} 