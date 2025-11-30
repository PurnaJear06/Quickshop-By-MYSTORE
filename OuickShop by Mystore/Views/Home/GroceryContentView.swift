import SwiftUI
import UIKit

struct GroceryContentView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // State for animations
    @State private var animateContent = false
    @State private var addingToCartItems: [String: Bool] = [:]
    
    var body: some View {
        // Content sections with white background
        VStack(spacing: 0) {
            // Grocery Essentials heading
            Text("Grocery Essentials")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 20)
            
            // Grocery categories section - Updated with grocery-relevant categories
            groceryCategoriesSection
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
    
    // MARK: - Grocery Categories Section (Updated)
    private var groceryCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Grid of grocery categories - Updated to be grocery-relevant
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                categoryCard(name: "Fresh Fruits", icon: "leaf.fill", bgColor: Color(hex: "FFE8E8"))
                categoryCard(name: "Vegetables", icon: "leaf.fill", bgColor: Color(hex: "E8FFE8"))
                categoryCard(name: "Dairy", icon: "drop.fill", bgColor: Color(hex: "E8F0FF"))
                categoryCard(name: "Snacks", icon: "gift.fill", bgColor: Color(hex: "FFF0E8"))
                categoryCard(name: "Beverages", icon: "cup.and.saucer.fill", bgColor: Color(hex: "F0E8FF"))
                categoryCard(name: "Pantry", icon: "house.fill", bgColor: Color(hex: "FFE8F0"))
            }
            .padding(.horizontal, 16)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    private func categoryCard(name: String, icon: String, bgColor: Color) -> some View {
        NavigationLink(destination: ProductListView(categoryTitle: name, categoryType: "category")) {
            VStack(spacing: 8) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(bgColor)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)
                
                // Category name
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "F9F9F9"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Hot Selling Section (New Addition)
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
            HotSellingProduct(id: "hs1", name: "Fresh Bananas", price: 49, originalPrice: 59, discount: 17, deliveryTime: "8 MINS", icon: "leaf.fill", rating: 4.3, reviews: 178),
            HotSellingProduct(id: "hs2", name: "Organic Milk", price: 89, originalPrice: 99, discount: 10, deliveryTime: "10 MINS", icon: "drop.fill", rating: 4.6, reviews: 234),
            HotSellingProduct(id: "hs3", name: "Bread Loaf", price: 25, originalPrice: 30, discount: 17, deliveryTime: "6 MINS", icon: "birthday.cake.fill", rating: 4.2, reviews: 156),
            HotSellingProduct(id: "hs4", name: "Rice Pack", price: 299, originalPrice: 349, discount: 14, deliveryTime: "15 MINS", icon: "house.fill", rating: 4.4, reviews: 189),
            HotSellingProduct(id: "hs5", name: "Tea Bags", price: 149, originalPrice: 179, discount: 17, deliveryTime: "12 MINS", icon: "cup.and.saucer.fill", rating: 4.1, reviews: 267),
            HotSellingProduct(id: "hs6", name: "Fresh Eggs", price: 79, originalPrice: 89, discount: 11, deliveryTime: "9 MINS", icon: "circle.fill", rating: 4.5, reviews: 145)
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
                    .background(Color("primaryRed"))
                    .cornerRadius(4)
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
            
            // ADD button using ConsistentButton
            ConsistentButton.small(
                title: "ADD",
                action: {
                    // Create a mock product for cart
                    let mockProduct = Product(
                        id: product.id,
                        name: product.name,
                        description: "Grocery essential item",
                        price: Double(product.originalPrice),
                        mrp: Double(product.price) * 2,
                        imageURL: "",
                        category: "Grocery",
                        isAvailable: true,
                        isFeatured: true,
                        weight: "1 unit",
                        stockQuantity: 100,  // Increased from 10 to 100
                        gst: 5.0  // Default 5% GST
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



#Preview {
    GroceryContentView()
        .environmentObject(CartViewModel())
        .environmentObject(HomeViewModel())
} 