import SwiftUI
import UIKit

struct SummerContentView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // State for animations
    @State private var animateContent = false
    @State private var addingToCartItems: [String: Bool] = [:]
    
    var body: some View {
        // Content sections with white background
        VStack(spacing: 0) {
            // Summer Category heading
            Text("Summer Category")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
            // Summer categories section - Updated with grocery-relevant categories
            summerCategoriesSection
                .padding(.top, 16)
                
            // Hot selling section - New addition
            hotSellingSection
                .padding(.top, 20)
                .padding(.bottom, 80)
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Summer Categories Section (Updated)
    private var summerCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Grid of summer categories - Fixed alignment and spacing
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 20) {
                energyDrinksCard()
                soapsAndBodywashesCard()
                coolTalcumPowdersCard()
                categoryCard(name: "Frozen Foods", icon: "snowflake", bgColor: Color(hex: "F0E8FF"))
                categoryCard(name: "Beverages", icon: "drop.fill", bgColor: Color(hex: "E8FFE8"))
                categoryCard(name: "Fresh Salads", icon: "carrot.fill", bgColor: Color(hex: "FFE8F0"))
            }
            .padding(.horizontal, 16)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    private func categoryCard(name: String, icon: String, bgColor: Color) -> some View {
        VStack(spacing: 8) {
            // Card with consistent height and alignment
            NavigationLink(destination: ProductListView(categoryTitle: name, categoryType: "category")) {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: "F9F9F9"))
                        .frame(height: 110)
                        .cornerRadius(12)
                    
                    Circle()
                        .fill(bgColor)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                }
            }
            
            // Category name with consistent alignment
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Energy Drinks Category Card (Fixed)
    private func energyDrinksCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Energy drinks", categoryType: "category")) {
                Image("glucon_d_banner")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Energy drinks")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Soaps and Bodywashes Card (Fixed)
    private func soapsAndBodywashesCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Soaps and Bodywashes", categoryType: "category")) {
                Image("soaps_banner")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Soaps and\nBodywashes")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Cool Talcum Powders Card (Fixed)
    private func coolTalcumPowdersCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Cool Talcum Powders", categoryType: "category")) {
                Image("talcum_banner")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Cool Talcum\nPowders")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Hot Selling Section (Updated with Better Alignment)
    private var hotSellingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hot Selling")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
            
            // Product grid with improved spacing and alignment
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(hotSellingProducts, id: \.id) { product in
                    hotSellingProductCard(product: product)
                }
            }
            .padding(.horizontal, 16)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // Hot selling products data
    private var hotSellingProducts: [HotSellingProduct] {
        [
            HotSellingProduct(id: "hs1", name: "Fresh Watermelon", price: 49, originalPrice: 59, discount: 17, deliveryTime: "10 MINS", icon: "leaf.fill", rating: 4.2, reviews: 156),
            HotSellingProduct(id: "hs2", name: "Coconut Water", price: 35, originalPrice: 45, discount: 22, deliveryTime: "8 MINS", icon: "drop.fill", rating: 4.5, reviews: 89),
            HotSellingProduct(id: "hs3", name: "Ice Cream Tub", price: 199, originalPrice: 249, discount: 20, deliveryTime: "12 MINS", icon: "snow", rating: 4.1, reviews: 203),
            HotSellingProduct(id: "hs4", name: "Cold Coffee", price: 129, originalPrice: 149, discount: 13, deliveryTime: "15 MINS", icon: "cup.and.saucer.fill", rating: 4.3, reviews: 92),
            HotSellingProduct(id: "hs5", name: "Fresh Lemonade", price: 39, originalPrice: 49, discount: 20, deliveryTime: "7 MINS", icon: "drop.fill", rating: 4.4, reviews: 178),
            HotSellingProduct(id: "hs6", name: "Frozen Yogurt", price: 89, originalPrice: 109, discount: 18, deliveryTime: "14 MINS", icon: "snowflake", rating: 4.0, reviews: 134)
        ]
    }
    
    private func hotSellingProductCard(product: HotSellingProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image with discount badge
            ZStack(alignment: .topTrailing) {
                // Product image container with consistent aspect ratio
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                        .aspectRatio(1, contentMode: .fit)
                    
                    Image(systemName: product.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                // Discount badge with improved styling
                Text("\(product.discount)% OFF")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                    .shadow(color: Color.red.opacity(0.3), radius: 2, x: 0, y: 1)
                    .padding(6)
            }
            
            // Product details with consistent spacing
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.black)
                    .frame(height: 32, alignment: .top) // Fixed height for alignment
                
                // Delivery time
                HStack(spacing: 2) {
                    Image(systemName: "timer")
                        .font(.system(size: 9))
                        .foregroundColor(.green)
                    
                    Text(product.deliveryTime)
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                
                // Rating with consistent layout
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(product.rating) ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                    }
                    
                    Text("(\(product.reviews))")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
                
                // Price with better spacing
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("₹\(product.price)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("₹\(product.originalPrice)")
                        .font(.system(size: 9))
                        .strikethrough()
                        .foregroundColor(.gray)
                }
            }
            
            // Updated ADD button using ConsistentButton
            ConsistentButton.small(
                title: "ADD",
                action: {
                    // Create a mock product for cart
                    let mockProduct = Product(
                        id: product.id,
                        name: product.name,
                        description: "Summer special item",
                        price: Double(product.originalPrice),
                        mrp: Double(product.price) * 2,
                        imageURL: "",
                        category: "Summer",
                        isAvailable: true,
                        isFeatured: true,
                        weight: "1 unit",
                        stockQuantity: 100,  // Increased from 10 to 100
                        gst: 12.0  // Summer products typically have 12% GST
                    )
                    
                    cartViewModel.addToCart(product: mockProduct)
                }
            )
        }
        .frame(maxWidth: .infinity)  // Use flexible width instead of fixed
        .frame(height: 240)  // Consistent height for all cards
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Previews
struct SummerContentView_Previews: PreviewProvider {
    static var previews: some View {
        SummerContentView()
            .environmentObject(CartViewModel())
            .environmentObject(HomeViewModel())
    }
} 