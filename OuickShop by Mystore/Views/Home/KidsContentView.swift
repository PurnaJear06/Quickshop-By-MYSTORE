import SwiftUI

struct KidsContentView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // Animation state
    @State private var animateContent = false
    @State private var addingToCartItems: [String: Bool] = [:]

    var body: some View {
        // Content sections with white background
        VStack(spacing: 0) {
            // Kids Zone heading
            Text("Kids Zone")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 20)
            
            // Kids categories section - Updated with banner images
            kidsCategoriesSection
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
    
    // MARK: - Kids Categories Section (Updated with Banner Images)
    private var kidsCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Grid of kids categories with banner images
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 20) {
                soapsAndBodywashesCard()
                hairOilsCard()
                moisturizerAndFaceCreamsCard()
                toothPasteAndBrushesCard()
                shampooCard()
                combsAndAccessoriesCard()
            }
            .padding(.horizontal, 16)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // MARK: - Banner Card Functions
    
    // 1. Soaps and Body washes Card
    private func soapsAndBodywashesCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Soaps and Body washes", categoryType: "category")) {
                Image("kids_soaps_bodywashes")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Soaps and\nBody washes")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // 2. Hair Oils Card
    private func hairOilsCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Hair Oils", categoryType: "category")) {
                Image("kids_hair_oils")
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
    
    // 3. Moisturizer and Face Creams Card
    private func moisturizerAndFaceCreamsCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Moisturizer and Face Creams", categoryType: "category")) {
                Image("kids_moisturizer_facecreams")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Moisturizer and\nFace Creams")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // 4. Tooth Paste and Brushes Card
    private func toothPasteAndBrushesCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Tooth Paste and Brushes", categoryType: "category")) {
                Image("kids_toothpaste_brushes")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Tooth Paste and\nBrushes")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // 5. Shampoo Card
    private func shampooCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Shampoo", categoryType: "category")) {
                Image("kids_shampoo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Shampoo")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // 6. Combs and Accessories Card
    private func combsAndAccessoriesCard() -> some View {
        VStack(spacing: 8) {
            // Banner card with consistent height
            NavigationLink(destination: ProductListView(categoryTitle: "Combs and Accessories", categoryType: "category")) {
                Image("kids_combs_accessories")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
            }
            
            // Category name with consistent alignment and height
            Text("Combs and\nAccessories")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity)
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
            HotSellingProduct(id: "hs1", name: "Learning Tablet", price: 1999, originalPrice: 2499, discount: 20, deliveryTime: "30 MINS", icon: "gamecontroller.fill", rating: 4.4, reviews: 189),
            HotSellingProduct(id: "hs2", name: "Story Books Set", price: 399, originalPrice: 499, discount: 20, deliveryTime: "25 MINS", icon: "book.fill", rating: 4.6, reviews: 234),
            HotSellingProduct(id: "hs3", name: "Art Kit", price: 799, originalPrice: 999, discount: 20, deliveryTime: "20 MINS", icon: "paintpalette.fill", rating: 4.3, reviews: 156),
            HotSellingProduct(id: "hs4", name: "Kids T-Shirt", price: 299, originalPrice: 399, discount: 25, deliveryTime: "35 MINS", icon: "tshirt.fill", rating: 4.2, reviews: 178),
            HotSellingProduct(id: "hs5", name: "Puzzle Game", price: 199, originalPrice: 249, discount: 20, deliveryTime: "15 MINS", icon: "puzzlepiece.fill", rating: 4.5, reviews: 145),
            HotSellingProduct(id: "hs6", name: "Baby Lotion", price: 149, originalPrice: 199, discount: 25, deliveryTime: "12 MINS", icon: "heart.fill", rating: 4.1, reviews: 267)
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
                        description: "Kids special item",
                        price: Double(product.originalPrice),
                        discountPrice: Double(product.price),
                        imageURL: "",
                        category: "Kids",
                        isAvailable: true,
                        isFeatured: true,
                        weight: "1 unit",
                        stockQuantity: 100  // Increased from 10 to 100
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
struct KidsContentView_Previews: PreviewProvider {
    static var previews: some View {
        KidsContentView()
            .environmentObject(CartViewModel())
            .environmentObject(HomeViewModel())
    }
}
