import SwiftUI

struct SearchView: View {
    // Environment objects
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    
    // State
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    @State private var recentSearches = ["Net Curtain", "Plates", "Condoms", "Party Prop...", "Paper Plates", "Advance"]
    @Environment(\.dismiss) private var dismiss
    
    // Popular categories data
    private let popularCategories = [
        ("Paneer", "cart.fill", Color.green),
        ("Toys", "gamecontroller.fill", Color.blue),
        ("Home Decor", "house.fill", Color.orange),
        ("Safety Shield", "shield.fill", Color.purple)
    ]
    
    // Computed properties
    private var searchResults: [Product] {
        if searchText.isEmpty {
            return []
        } else {
            return homeViewModel.products.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                searchHeader
                
                if !searchText.isEmpty {
                    // Search Results
                    searchResultsSection
                } else {
                    // Default Content - Past Searches, Banner, Popular Categories
                    ScrollView {
                        VStack(spacing: 24) {
                            // Past Searches Section
                            pastSearchesSection
                            
                            // Promotional Banner
                            promotionalBanner
                            

                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color(hex: "F8F9FA").ignoresSafeArea())
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Back button
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    
                    TextField("Search for 'Smart Watch'", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showCancelButton = true
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Voice search button
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color("primaryRed"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "F1F1F1"))
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }
    
    // MARK: - Past Searches Section
    private var pastSearchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("YOUR PAST SEARCHES")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Past search pills
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(recentSearches.indices, id: \.self) { index in
                    if index < recentSearches.count {
                        pastSearchPill(recentSearches[index])
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func pastSearchPill(_ search: String) -> some View {
        Button(action: {
            searchText = search
        }) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(search)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Promotional Banner
    private var promotionalBanner: some View {
        VStack(spacing: 0) {
            Button(action: {
                // Navigate to back to school sale
            }) {
                ZStack {
                    // Gradient background similar to Swiggy
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "4A5D7A"), Color(hex: "6B7B95")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(12)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stationery, sports supplies, breakfast picks & more")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Explore our Back To")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("School Sale")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // School bag illustration
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "backpack.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color("primaryRed"))
                        }
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(20)
                }
                .frame(height: 120)
            }
            .padding(.horizontal, 16)
        }
    }
    

    
    // MARK: - Search Results Section
    private var searchResultsSection: some View {
        VStack(spacing: 0) {
            if searchResults.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No products found")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Try searching for something else")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 100)
            } else {
                // Search results list
                List {
                    ForEach(searchResults) { product in
                        SearchResultRow(product: product)
                            .onTapGesture {
                                // Add to recent searches
                                if !recentSearches.contains(product.name) {
                                    recentSearches.insert(product.name, at: 0)
                                    if recentSearches.count > 6 {
                                        recentSearches.removeLast()
                                    }
                                }
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
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
        NavigationLink(destination: ProductDetailView(product: product)) {
            HStack(spacing: 12) {
                // Product Image
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(CategoryIconMap.colorName(for: product.category).opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: CategoryIconMap.iconName(for: product.category))
                        .font(.system(size: 24))
                        .foregroundColor(CategoryIconMap.colorName(for: product.category))
                }
                
                // Product Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(product.weight)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        // Price display
                        VStack(alignment: .leading, spacing: 2) {
                            if let mrp = product.mrp, mrp > product.price {
                                Text("₹\(Int(mrp))")
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                                Text("₹\(Int(product.price))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            } else {
                                Text("₹\(Int(product.price))")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Enhanced Add to Cart Button
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
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color("primaryRed"))
                                .cornerRadius(4, corners: [.topLeft, .bottomLeft])
                        }
                        
                        // Quantity Display
                        Text("\(cartQuantity)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 28, height: 24)
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
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color("primaryRed"))
                                .cornerRadius(4, corners: [.topRight, .bottomRight])
                        }
                    }
                    .scaleEffect(addingToCart ? 0.95 : 1.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
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
                        HStack(spacing: 4) {
                            if showAddedFeedback {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(showAddedFeedback ? "ADDED" : "ADD")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(showAddedFeedback ? Color("primaryGreen") : Color("primaryRed"))
                        )
                        .scaleEffect(addingToCart ? 0.95 : 1.0)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SearchView()
        .environmentObject(HomeViewModel())
        .environmentObject(CartViewModel())
} 