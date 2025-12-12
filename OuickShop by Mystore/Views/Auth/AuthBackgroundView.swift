import SwiftUI

struct AuthBackgroundView: View {
    // Properties
    var opacity: Double = 0.1
    
    // Sample product images
    private let productImages = [
        "banana.fill", "carrot.fill", "leaf.fill", "bolt.fill",
        "pills.fill", "oilcan.fill", "greetingcard.fill", "lightbulb.fill",
        "soap.fill", "cup.and.saucer.fill", "fork.knife", "takeoutbag.and.cup.and.straw.fill"
    ]
    
    // Grid layout
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background color
            Color("bgLight").ignoresSafeArea()
            
            // Product grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<12) { index in
                        productCell(index: index)
                    }
                }
                .padding()
            }
            .disabled(true)
            
            // Overlay to fade out the grid
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("bgLight").opacity(0.8),
                    Color("bgLight").opacity(0.9),
                    Color("bgLight")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .opacity(opacity)
    }
    
    // Product cell view
    private func productCell(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .frame(height: 120)
            
            VStack {
                Image(systemName: productImages[index % productImages.count])
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("primaryBlue"))
                    .frame(width: 50, height: 50)
                
                Text(getProductName(for: index))
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(10)
        }
        .rotationEffect(.degrees(Double.random(in: -3...3)))
    }
    
    // Helper function to get product names
    private func getProductName(for index: Int) -> String {
        let names = [
            "Fresh Bananas", "Organic Carrots", "Spinach", "Energy Drink",
            "Medicines", "Engine Oil", "Greeting Card", "Light Bulb",
            "Handwash", "Coffee Mug", "Cutlery Set", "Takeout Meal"
        ]
        return names[index % names.count]
    }
}

// Extension to use this as an overlay
extension View {
    func withProductBackground(opacity: Double = 0.1) -> some View {
        ZStack {
            AuthBackgroundView(opacity: opacity)
            self
        }
    }
}

#Preview {
    AuthBackgroundView()
} 