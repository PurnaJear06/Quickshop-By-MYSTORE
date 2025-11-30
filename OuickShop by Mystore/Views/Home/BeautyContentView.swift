import SwiftUI

struct BeautyContentView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // State for animations
    @State private var animateContent = false
    @State private var addingToCartItems: [String: Bool] = [:]
    
    var body: some View {
        // Content sections with white background
        VStack(spacing: 0) {
            // Beauty Zone heading
            Text("Beauty Zone")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
            // Beauty categories section - Updated with banner images
            beautyCategoriesSection
                .padding(.top, 16)
                
            // Hot selling section
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
    
    // MARK: - Beauty Categories Section (Updated with Banner Images)
    private var beautyCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Grid of beauty categories with banner images - consistent with Summer page
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 20) {
                hairOilsCard()
                hairWashesAndDyesCard()
                brushesAndToothpasteCard()
                perfumesRollOnCard()
                mensGroomingCard()
                beautyToolsCard()
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
    
    // MARK: - Hair Oils Card
    private func hairOilsCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Hair Oils", categoryType: "category")) {
                Image("hair_oils")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Hair Oils")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Hair Washes and Dyes Card
    private func hairWashesAndDyesCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Hair Washes & Dyes", categoryType: "category")) {
                Image("hair_washes_dyes")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Hair Washes\n& Dyes")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Brushes and Toothpaste Card
    private func brushesAndToothpasteCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Brushes & Toothpaste", categoryType: "category")) {
                Image("brushes_toothpaste")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Brushes &\nToothpaste")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Perfumes and Roll On Card
    private func perfumesRollOnCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Perfumes & Roll On", categoryType: "category")) {
                Image("perfumes_roll_on")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Perfumes &\nRoll On")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Men's Grooming Products Card
    private func mensGroomingCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Men's Grooming", categoryType: "category")) {
                Image("mens_grooming")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Men's Grooming\nProducts")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Beauty Tools Card
    private func beautyToolsCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Beauty Tools", categoryType: "category")) {
                Image("beauty_tools")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Beauty Tools")
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
            HotSellingProduct(id: "hs1", name: "Face Moisturizer", price: 299, originalPrice: 399, discount: 25, deliveryTime: "15 MINS", icon: "drop.fill", rating: 4.5, reviews: 234),
            HotSellingProduct(id: "hs2", name: "Lipstick Set", price: 599, originalPrice: 799, discount: 25, deliveryTime: "12 MINS", icon: "paintpalette.fill", rating: 4.3, reviews: 156),
            HotSellingProduct(id: "hs3", name: "Hair Serum", price: 449, originalPrice: 549, discount: 18, deliveryTime: "10 MINS", icon: "scissors", rating: 4.2, reviews: 189),
            HotSellingProduct(id: "hs4", name: "Perfume Spray", price: 899, originalPrice: 1199, discount: 25, deliveryTime: "8 MINS", icon: "flame.fill", rating: 4.6, reviews: 312),
            HotSellingProduct(id: "hs5", name: "Foundation", price: 799, originalPrice: 999, discount: 20, deliveryTime: "14 MINS", icon: "paintpalette.fill", rating: 4.1, reviews: 278),
            HotSellingProduct(id: "hs6", name: "Nail Polish", price: 199, originalPrice: 249, discount: 20, deliveryTime: "16 MINS", icon: "hand.raised.fill", rating: 4.0, reviews: 145)
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
            
            // ADD button using ConsistentButton
            ConsistentButton.small(
                title: "ADD",
                action: {
                    // Create a mock product for cart
                    let mockProduct = Product(
                        id: product.id,
                        name: product.name,
                        description: "Beauty special item",
                        price: Double(product.originalPrice),
                        mrp: Double(product.price) * 2,
                        imageURL: "",
                        category: "Beauty",
                        isAvailable: true,
                        isFeatured: true,
                        weight: "1 unit",
                        stockQuantity: 100,  // Increased from 10 to 100
                        gst: 18.0  // Beauty products typically have 18% GST
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
struct BeautyContentView_Previews: PreviewProvider {
    static var previews: some View {
        BeautyContentView()
            .environmentObject(CartViewModel())
            .environmentObject(HomeViewModel())
    }
} 