import SwiftUI

struct ConsistentButton: View {
    let title: String
    let action: () -> Void
    var backgroundColor: Color = Color("primaryRed")
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 8
    var fontSize: CGFloat = 16
    var fontWeight: Font.Weight = .bold
    var horizontalPadding: CGFloat = 20
    var verticalPadding: CGFloat = 12
    var isEnabled: Bool = true
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            Text(title)
                .font(.system(size: fontSize, weight: fontWeight))
                .foregroundColor(foregroundColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    backgroundColor
                        .opacity(isEnabled ? 1.0 : 0.5)
                )
                .cornerRadius(cornerRadius)
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Convenience Initializers
extension ConsistentButton {
    // Primary Button (Red)
    static func primary(
        title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true
    ) -> ConsistentButton {
        ConsistentButton(
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
    ) -> ConsistentButton {
        ConsistentButton(
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
        isEnabled: Bool = true
    ) -> ConsistentButton {
        ConsistentButton(
            title: title,
            action: action,
            backgroundColor: backgroundColor,
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
        ConsistentButton.primary(title: "Primary Button") {}
        ConsistentButton.secondary(title: "Secondary Button") {}
        ConsistentButton.small(title: "ADD") {}
    }
    .padding()
} 