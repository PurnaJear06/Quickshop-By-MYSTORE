import SwiftUI

struct ElectronicsView: View {
    // Environment objects
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    
    // Animation states
    @State private var isAppearing = false
    @State private var animateContent = false
    @State private var showBackToTop = false
    @State private var scrollOffset: CGFloat = 0
    @State private var addingToCartItems: [String: Bool] = [:]
    @State private var showingSearch = false
    
    // Namespace for matched geometry effect when transitioning
    @Namespace private var electronicsTransition
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main background
            Color("backgroundCream")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    // Scroll position detector
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self,
                                        value: geometry.frame(in: .named("scrollView")).minY)
                    }
                    .frame(height: 0)
                    
                    // Content
                    VStack(spacing: 0) {
                        // Category row
                        categoryRow
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Electronics banner
                        electronicsBanner
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Featured section
                        featuredSection
                            .padding(.top, 24)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Product grid
                        productGrid
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .padding(.bottom, 80)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                    }
                }
                .coordinateSpace(name: "scrollView")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                    showBackToTop = value < -150
                }
                .refreshable {
                    // Simulate refresh
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                }
            }
        }
        .opacity(isAppearing ? 1 : 0)
        .scaleEffect(isAppearing ? 1 : 0.95)
        .onAppear {
            // Animate content appearance
            withAnimation(.easeOut(duration: 0.3)) {
                isAppearing = true
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                animateContent = true
            }
        }
        .onDisappear {
            // Reset animations for next appearance
            isAppearing = false
            animateContent = false
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSearch) {
            SearchView()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        ZStack {
            // Header background - light purple
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.15),
                    Color.purple.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 172)
            
            VStack(spacing: 0) {
                // Status bar height compensation
                Color.clear
                    .frame(height: getSafeAreaTop())
                
                // Top part with back button, title, and icons
                HStack {
                    // Back button
                    Button(action: {
                        // Animate exit
                        withAnimation(.easeIn(duration: 0.2)) {
                            isAppearing = false
                            animateContent = false
                        }
                        
                        // Wait for animation to complete before dismissing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            homeViewModel.selectCategory(nil)
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    // Title with matchedGeometryEffect
                    Text("Electronics")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .matchedGeometryEffect(id: "electronicsTitle", in: electronicsTransition)
                    
                    Spacer()
                    
                    // Cart button
                    Button(action: {}) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            
                            // Cart badge
                            if !cartViewModel.cartItems.isEmpty {
                                Text("\(cartViewModel.cartItems.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Color("primaryYellow"))
                                    .clipShape(Circle())
                                    .offset(x: 5, y: -5)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                
                // Search bar
                Button(action: {
                    showingSearch = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                        
                        Text("Search in Electronics")
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Image(systemName: "mic")
                            .foregroundColor(.gray)
                            .padding(.trailing, 12)
                    }
                    .frame(height: 46)
                    .background(Color.white)
                    .cornerRadius(22)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
            }
        }
    }
    
    // MARK: - Category Row
    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                categoryItem(icon: "headphones", title: "Audio", selected: true)
                categoryItem(icon: "iphone", title: "Phones", selected: false)
                categoryItem(icon: "desktopcomputer", title: "Computers", selected: false)
                categoryItem(icon: "tv", title: "TVs", selected: false)
                categoryItem(icon: "camera.fill", title: "Cameras", selected: false)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func categoryItem(icon: String, title: String, selected: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(selected ? Color.purple.opacity(0.15) : Color.white)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(selected ? Color.purple : Color.black.opacity(0.7))
            }
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(selected ? Color.purple : Color.black.opacity(0.7))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    // MARK: - Electronics Banner
    private var electronicsBanner: some View {
        ZStack(alignment: .center) {
            // Background image - Replace with your actual image
            Image("banner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.4),
                                    Color.blue.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            // Content overlay
            VStack(spacing: 12) {
                Text("TECH")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.blue)
                
                Text("GADGETS")
                    .font(.system(size: 46, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Headphones
                    featuredCard(
                        title: "Premium Audio",
                        imageName: "headphones",
                        color: Color.purple.opacity(0.15),
                        iconColor: Color.purple,
                        tag: "Featured"
                    )
                    
                    // Smartphones
                    featuredCard(
                        title: "Latest Smartphones",
                        imageName: "iphone",
                        color: Color.blue.opacity(0.15),
                        iconColor: Color.blue,
                        tag: "New"
                    )
                    
                    // Brand in Focus - Apple
                    VStack(alignment: .center, spacing: 8) {
                        // Tag
                        Text("Brand In Focus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.purple)
                            .cornerRadius(8)
                            .padding(.top, 10)
                        
                        Spacer()
                        
                        Text("SONY")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Premium Electronics")
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
                    .background(Color.purple)
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
    
    // MARK: - Product Grid
    private var productGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Best Sellers")
                .font(.system(size: 20, weight: .bold))
            
            // Product grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(1...8, id: \.self) { index in
                    let name = "Tech Item \(index)"
                    productItem(
                        name: name,
                        price: "₹\(999 + index * 500)",
                        icon: techIcons[index % techIcons.count]
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
                
                Text("High Quality")
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
    
    // Sample icons for tech items
    private let techIcons = [
        "headphones",
        "iphone",
        "desktopcomputer",
        "tv",
        "camera.fill",
        "airpods",
        "applewatch",
        "beats.headphones"
    ]
    
    // Helper to get the safe area top
    private func getSafeAreaTop() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.top ?? 0
    }
}

// Preview
struct ElectronicsView_Previews: PreviewProvider {
    static var previews: some View {
        ElectronicsView()
            .environmentObject(HomeViewModel())
            .environmentObject(CartViewModel())
    }
} 