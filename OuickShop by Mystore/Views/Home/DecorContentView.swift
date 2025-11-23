import SwiftUI

struct DecorContentView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // State for animations and transitions
    @State private var scrollOffset: CGFloat = 0
    @State private var animateContent = false
    @State private var isAppearing = false
    @State private var addingToCartItems: [String: Bool] = [:]
    
    // Namespace for matched geometry effect when transitioning
    @Namespace private var decorTransition
    
    var body: some View {
        // No outer VStack to allow full-width content
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Full-width decor banner with light blue background
                decorBanner
                    .opacity(animateContent ? 1 : 0)
                
                // Category row
                categoryRow
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                
                // Collections section
                collectionsSection
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                
                // Featured section
                featuredSection
                    .padding(.top, 24)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                
                // Home essentials section
                homeEssentialsSection
                    .padding(.top, 24)
                    .padding(.bottom, 80)
                    .padding(.horizontal, 16)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
            }
        }
        .refreshable {
            // Simulate refresh
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }
        .edgesIgnoringSafeArea(.top) // Allow content to extend to the top of the screen
        .onAppear {
            // Make content appear immediately with minimal animation delay
            isAppearing = true
            
            // Very fast animation for content to appear immediately
            withAnimation(.easeOut(duration: 0.05)) {
                animateContent = true
            }
        }
        .onDisappear {
            // Reset animations for next appearance
            isAppearing = false
            animateContent = false
        }
    }
    
    // MARK: - Decor Banner
    private var decorBanner: some View {
        ZStack(alignment: .center) {
            // Light blue background
            Rectangle()
                .fill(Color.blue.opacity(0.15))
                .frame(height: 140)
            
            VStack(spacing: 12) {
                Text("HOME")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("DECOR")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.black)
            }
            
            // Decoration items at the bottom
            HStack(spacing: 40) {
                Image(systemName: "lamp.table.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue.opacity(0.7))
                
                Image(systemName: "sofa.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue.opacity(0.7))
                
                Image(systemName: "bed.double.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue.opacity(0.7))
                
                Image(systemName: "house.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue.opacity(0.7))
            }
            .offset(y: 40)
        }
        .padding(.bottom, 20) // To account for the offset icons
    }
    
    // MARK: - Category Row
    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                categoryItem(icon: "sofa.fill", title: "Furniture", selected: true)
                categoryItem(icon: "lightbulb.fill", title: "Lighting", selected: false)
                categoryItem(icon: "paintbrush.fill", title: "Decor", selected: false)
                categoryItem(icon: "bed.double.fill", title: "Bedroom", selected: false)
                categoryItem(icon: "archivebox.fill", title: "Storage", selected: false)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func categoryItem(icon: String, title: String, selected: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(selected ? Color.blue.opacity(0.15) : Color.white)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(selected ? Color.blue : Color.black.opacity(0.7))
            }
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(selected ? Color.blue : Color.black.opacity(0.7))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    // MARK: - Collections Section
    private var collectionsSection: some View {
        VStack(spacing: 16) {
            // Row 1: Living Room, Bedroom
            HStack(spacing: 16) {
                collectionCard(
                    title: "Living Room",
                    products: [
                        ("Sofa Set", "sofa.fill"),
                        ("Coffee Table", "table.furniture"),
                        ("Throw Pillows", "square.fill"),
                        ("Wall Art", "rectangle.fill")
                    ]
                )
                
                collectionCard(
                    title: "Bedroom",
                    products: [
                        ("Bed Frame", "bed.double.fill"),
                        ("Nightstand", "table.furniture"),
                        ("Bedding", "rectangle.fill"),
                        ("Lamps", "lightbulb.fill")
                    ]
                )
            }
            
            // Row 2: Kitchen & Dining
            collectionCard(
                title: "Kitchen & Dining",
                products: [
                    ("Dinnerware", "circle.fill"),
                    ("Cookware", "flame.fill"),
                    ("Cutlery", "fork.knife"),
                    ("Servingware", "tray.fill")
                ]
            )
        }
    }
    
    // Collection Card
    private func collectionCard(title: String, products: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("textGray"))
                .padding(.top, 12)
                .padding(.leading, 14)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(products, id: \.0) { product in
                    VStack(spacing: 6) {
                        Image(systemName: product.1)
                            .font(.system(size: 20))
                            .foregroundColor(Color.blue)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                        
                        Text(product.0)
                            .font(.system(size: 10))
                            .foregroundColor(Color("textGray"))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
    }
    
    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Wall Decor
                    featuredCard(
                        title: "Wall Decor",
                        imageName: "photo.artframe",
                        color: Color.blue.opacity(0.15),
                        iconColor: Color.blue,
                        tag: "Featured"
                    )
                    
                    // Cushions
                    featuredCard(
                        title: "Cushions & Throws",
                        imageName: "square.fill",
                        color: Color.orange.opacity(0.15),
                        iconColor: Color.orange,
                        tag: "Featured"
                    )
                    
                    // Brand in Focus - IKEA
                    VStack(alignment: .center, spacing: 8) {
                        // Tag
                        Text("Brand In Focus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.top, 10)
                        
                        Spacer()
                        
                        Text("IKEA")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Swedish Furniture")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .frame(width: 170, height: 200)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.trailing, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
    }
    
    private func featuredCard(title: String, imageName: String, color: Color, iconColor: Color, tag: String) -> some View {
        VStack(alignment: .center, spacing: 0) {
            // Tag
            HStack {
                Text(tag)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.blue)
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding(.top, 10)
            .padding(.leading, 10)
            
            // Icon
            Image(systemName: imageName)
                .font(.system(size: 60))
                .foregroundColor(iconColor)
                .frame(height: 100)
                .padding(.top, 20)
            
            Spacer()
            
            // Title
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.bottom, 15)
        }
        .frame(width: 170, height: 200)
        .background(color)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Home Essentials Section
    private var homeEssentialsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Home Essentials")
                .font(.system(size: 20, weight: .bold))
            
            // Product grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(1...8, id: \.self) { index in
                    let name = "Decor Item \(index)"
                    productItem(
                        name: name,
                        price: "₹\(199 + index * 100)",
                        icon: decorIcons[index % decorIcons.count]
                    )
                }
            }
        }
    }
    
    // Product item
    private func productItem(name: String, price: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product image
            ZStack(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                    
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                // Wishlist button
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .padding(8)
            }
            
            // Product details
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.black)
                
                Text("Premium Quality")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack {
                    Text(price)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Add to cart button
                    Button(action: {
                        withAnimation {
                            addingToCartItems[name] = true
                            
                            // Add item to cart
                            cartViewModel.addToCart(name: name, price: price, quantity: 1)
                            
                            // Reset animation after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                addingToCartItems[name] = false
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(addingToCartItems[name] == true ? Color.green : Color("primaryYellow"))
                                .frame(width: 30, height: 30)
                            
                            if addingToCartItems[name] == true {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Sample icons for decor items
    private let decorIcons = [
        "lamp.table.fill",
        "sofa.fill",
        "bed.double.fill",
        "chair.fill",
        "tv.fill",
        "photo.artframe",
        "clock.fill",
        "peacesign"
    ]
}

struct DecorContentView_Previews: PreviewProvider {
    static var previews: some View {
        DecorContentView()
            .environmentObject(HomeViewModel())
            .environmentObject(CartViewModel())
    }
} 