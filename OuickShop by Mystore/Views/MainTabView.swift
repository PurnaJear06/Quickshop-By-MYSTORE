import SwiftUI

struct MainTabView: View {
    // Environment objects
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    // State
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $selectedTab) {
                // Home Tab
                HomeView()
                    .tag(0)
                
                // Order Again Tab
                OrderAgainView()
                    .tag(1)
                
                // Cart Tab
                CartView()
                    .tag(2)
                
                // Profile/Login Tab
                profileOrLoginView
                    .tag(3)
            }
            
            // Custom Tab Bar - Fixed layout constraints
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(0..<4) { index in
                        let tabInfo = getTabInfo(for: index)
                        blinkitTabButton(
                            index: index, 
                            title: tabInfo.title, 
                            icon: tabInfo.icon, 
                            selectedIcon: tabInfo.selectedIcon
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .top
                )
            }
            .ignoresSafeArea(.keyboard)
            }
        }
        .navigationBarHidden(true)
    }
    
    // Helper to get tab information
    private func getTabInfo(for index: Int) -> (title: String, icon: String, selectedIcon: String) {
        switch index {
        case 0:
            return ("Home", "house", "house.fill")
        case 1:
            return ("Order Again", "clock.arrow.circlepath", "clock.arrow.circlepath")
        case 2:
            return ("Cart", "cart", "cart.fill")
        case 3:
            return ("Profile", "person", "person.fill")
        default:
            return ("", "", "")
        }
    }
    
    // Improved tab button with better spacing and alignment
    private func blinkitTabButton(index: Int, title: String, icon: String, selectedIcon: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
                            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == index {
                        Circle()
                            .fill(Color("blinkitYellow"))
                            .frame(width: 36, height: 36)
                    }
                    
                    Image(systemName: selectedTab == index ? selectedIcon : icon)
                        .font(.system(size: selectedTab == index ? 16 : 14))
                        .foregroundColor(selectedTab == index ? .black : .gray.opacity(0.8))
                }
                .frame(width: 36, height: 36)
                
                Text(title)
                    .font(.system(size: 9))
                    .fontWeight(selectedTab == index ? .medium : .regular)
                    .foregroundColor(selectedTab == index ? .black : .gray.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .overlay(
                Group {
                    if index == 2 && cartViewModel.cartItems.count > 0 {
                ZStack {
                    Circle()
                        .fill(Color("primaryYellow"))
                        .frame(width: 18, height: 18)
                    
                    Text("\(cartViewModel.cartItems.count)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                }
                        .offset(x: 12, y: -14) // Adjusted badge position
                    }
                },
                alignment: .topTrailing
            )
        }
    }
    
    // Computed property to return either profile or login view
    private var profileOrLoginView: some View {
        Group {
            if userViewModel.isLoggedIn {
                ProfileView()
            } else {
                AuthView()
            }
        }
    }
}

// Modern Order Again View
struct OrderAgainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State private var showingSearch = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Order Again")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { 
                        // Properly show search
                        showingSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if userViewModel.isLoggedIn && !userViewModel.orders.isEmpty {
                    recentOrdersSection
                } else {
                    notLoggedInOrNoOrdersView
                }
                
                // Directly show recommended products - removed Shop by Category section
                recommendedProductsSection
            }
            .padding(.bottom, 100) // Increased bottom padding to ensure content doesn't get cut off
            .sheet(isPresented: $showingSearch) {
                // Add search functionality
                OrderAgainSearchView()
            }
        }
    }
    
    // Recent orders section with consistent layout
    private var recentOrdersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Orders")
                .font(.headline)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(userViewModel.orders.prefix(3)) { order in
                        recentOrderCard(order: order)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Recent order card with consistent width
    private func recentOrderCard(order: Order) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Order date and status
            HStack {
                Text("Order #\(order.id)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(daysAgo(from: order.orderDate))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // Show up to 3 items from the order
            ForEach(order.items.prefix(3)) { item in
                HStack(spacing: 12) {
                    Image(systemName: CategoryIconMap.iconName(for: item.product.category))
                        .foregroundColor(.gray)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text(item.product.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("x\(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // If there are more items, show a count
            if order.items.count > 3 {
                Text("+ \(order.items.count - 3) more items")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // Reorder button - using consistent primaryYellow color
            Button(action: {
                reorderItems(from: order)
            }) {
                HStack {
                    Spacer()
                    Text("Reorder")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(Color("primaryYellow"))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .frame(width: 280)
    }
    
    // Not logged in or no orders view
    private var notLoggedInOrNoOrdersView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.6))
            
            Text(userViewModel.isLoggedIn ? "No orders yet" : "Sign in to see your orders")
                .font(.headline)
            
            Button(action: {
                // Navigate to login or explore products
            }) {
                Text(userViewModel.isLoggedIn ? "Start shopping" : "Sign in")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 24)
                    .background(Color("primaryYellow")) // Using consistent color
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // Recommended products section with improved layout and functionality
    private var recommendedProductsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended for you")
                .font(.headline)
                .padding(.leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(getRecommendedProducts()) { product in
                    recommendedProductCard(product: product)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    // Recommended product card with improved layout and navigation
    private func recommendedProductCard(product: Product) -> some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack(alignment: .leading, spacing: 8) {
                // Product image
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: CategoryIconMap.iconName(for: product.category))
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                    
                    // Discount badge if available
                    if let discountPercentage = product.discountPercentage {
                        Text("\(discountPercentage)% OFF")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color("primaryRed"))
                            .cornerRadius(4)
                            .padding(8)
                    }
                }
                
                // Product name and weight
                Text(product.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.black)
                    .frame(height: 40, alignment: .top)
                
                Text(product.weight)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                // Price and enhanced add button
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        if let mrp = product.mrp, mrp > product.price {
                            Text("₹\(Int(mrp))")
                                .font(.caption)
                                .strikethrough()
                                .foregroundColor(.gray)
                        }
                        Text("₹\(Int(product.price))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("primaryGreen"))
                    }
                    
                    Spacer()
                    
                    // Enhanced Add Button with Quantity Controls
                    EnhancedAddButton(product: product)
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain) // Makes only the NavigationLink area clickable
    }
    
    // Helper method to reorder items from a previous order
    private func reorderItems(from order: Order) {
        // Clear cart first if needed
        // cartViewModel.clearCart()
        
        // Add all items from the order to cart
        for item in order.items {
            cartViewModel.addToCart(product: item.product, quantity: item.quantity)
        }
    }
    
    // Helper method to get days ago string
    private func daysAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        if let days = components.day {
            if days == 0 {
                return "Today"
            } else if days == 1 {
                return "Yesterday"
            } else {
                return "\(days) days ago"
            }
        }
        return ""
    }
    
    // Helper method to get recommended products
    private func getRecommendedProducts() -> [Product] {
        // In a real app, this would use a recommendation algorithm
        // For now, we'll return a mix of popular products
        let allProducts = Product.sampleProducts
        return Array(allProducts.filter { $0.isFeatured }.prefix(6))
    }
}

// MARK: - Enhanced Add Button Component
struct EnhancedAddButton: View {
    let product: Product
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var addingToCart = false
    @State private var showAddedFeedback = false
    
    // Check if product is in cart and get quantity
    private var cartItem: CartItem? {
        cartViewModel.cartItems.first { $0.product.id == product.id }
    }
    
    private var isInCart: Bool {
        cartItem != nil
    }
    
    private var cartQuantity: Int {
        cartItem?.quantity ?? 0
    }
    
    var body: some View {
        if isInCart && cartQuantity > 0 {
            // Quantity Controls
            HStack(spacing: 0) {
                // Decrease Button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 0.15)) {
                        addingToCart = true
                    }
                    
                    if cartQuantity > 1 {
                        cartViewModel.updateQuantity(cartItemId: cartItem!.id, quantity: cartQuantity - 1)
                    } else {
                        cartViewModel.removeFromCart(cartItemId: cartItem!.id)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            addingToCart = false
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 20, height: 20)
                        .background(Color("primaryYellow"))
                        .cornerRadius(3, corners: [.topLeft, .bottomLeft])
                }
                
                // Quantity Display
                Text("\(cartQuantity)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 24, height: 20)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(Color.gray.opacity(0.3)),
                        alignment: .leading
                    )
                    .overlay(
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(Color.gray.opacity(0.3)),
                        alignment: .trailing
                    )
                
                // Increase Button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 0.15)) {
                        addingToCart = true
                    }
                    
                    cartViewModel.updateQuantity(cartItemId: cartItem!.id, quantity: cartQuantity + 1)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            addingToCart = false
                        }
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 20, height: 20)
                        .background(Color("primaryYellow"))
                        .cornerRadius(3, corners: [.topRight, .bottomRight])
                }
            }
            .scaleEffect(addingToCart ? 0.95 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        } else {
            // Add Button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.15)) {
                    addingToCart = true
                    showAddedFeedback = true
                }
                
                cartViewModel.addToCart(product: product)
                
                // Show success feedback
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        addingToCart = false
                    }
                    
                    // Hide success feedback after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAddedFeedback = false
                        }
                    }
                }
            }) {
                HStack(spacing: 3) {
                    if showAddedFeedback {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(showAddedFeedback ? "✓" : "+")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(showAddedFeedback ? Color("primaryGreen") : Color("primaryYellow"))
                )
                .scaleEffect(addingToCart ? 0.95 : 1.0)
            }
            .buttonStyle(.plain)
        }
    }
}

// Search view for the Order Again page
struct OrderAgainSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search products", text: $searchText)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                // Results would go here
                if !searchText.isEmpty {
                    let filteredProducts = homeViewModel.products.filter {
                        $0.name.lowercased().contains(searchText.lowercased()) ||
                        $0.category.lowercased().contains(searchText.lowercased())
                    }
                    
                    if filteredProducts.isEmpty {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding()
                            
                            Text("No results found for \"\(searchText)\"")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(filteredProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                HStack {
                                    Image(systemName: CategoryIconMap.iconName(for: product.category))
                                        .foregroundColor(.gray)
                                        .frame(width: 40, height: 40)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(product.name)
                                            .font(.headline)
                                        
                                        Text(product.category)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                } else {
                    // Show recent searches or suggestions
                    VStack {
                        Text("Try searching for products, categories, or brands")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}

// Original Categories View - keeping it for reference but it's not being used anymore
struct CategoriesView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                    ForEach(homeViewModel.categories) { category in
                        categoryCell(category: category)
                    }
                }
                .padding()
        }
        .navigationTitle("All Categories")
    }
    
    private func categoryCell(category: Category) -> some View {
        VStack {
            Image(systemName: CategoryIconMap.iconName(for: category.name))
                .font(.system(size: 40))
                .foregroundColor(Color("primaryBlue"))
                .frame(width: 80, height: 80)
                .background(Color("primaryBlue").opacity(0.1))
                .clipShape(Circle())
            
            Text(category.name)
                .font(.headline)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                homeViewModel.selectCategory(category.name)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(CartViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(HomeViewModel())
} 