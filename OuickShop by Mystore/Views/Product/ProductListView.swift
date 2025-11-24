import SwiftUI

struct ProductListView: View {
    // Environment objects
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // Properties
    let categoryTitle: String
    let categoryType: String // "banner", "category", "zone"
    
    // State
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var showingSortOptions = false
    @State private var selectedSortOption: SortOption = .popularity
    @State private var selectedFilters: FilterOptions = FilterOptions()
    @State private var animateProducts = false
    @Environment(\.dismiss) private var dismiss
    
    // Products data based on category from Firestore
    private var categoryProducts: [Product] {
        // Filter products from HomeViewModel based on category
        let normalizedCategoryTitle = categoryTitle.lowercased()
        
        // If no products loaded yet, return empty
        guard !homeViewModel.products.isEmpty else {
            print("⚠️ No products available in HomeViewModel")
            return []
        }
        
        let filtered = homeViewModel.products.filter { product in
            let normalizedProductCategory = product.category.lowercased()
            
            // Match category names with flexible matching
            let matches: Bool
            switch normalizedCategoryTitle {
            case "cookies & biscuits", "cookies", "biscuits":
                matches = normalizedProductCategory.contains("cookie") || normalizedProductCategory.contains("biscuit")
            case "milk and dairy", "dairy", "milk":
                matches = normalizedProductCategory.contains("dairy") || normalizedProductCategory.contains("milk")
            case "summer category", "summer":
                matches = normalizedProductCategory.contains("summer") || normalizedProductCategory.contains("beverage")
            case "beauty zone", "beauty":
                matches = normalizedProductCategory.contains("beauty") || normalizedProductCategory.contains("cosmetic")
            case "kids zone", "kids":
                matches = normalizedProductCategory.contains("kids") || normalizedProductCategory.contains("baby")
            case "grocery essentials", "grocery":
                matches = normalizedProductCategory.contains("grocery") || normalizedProductCategory.contains("essential")
            case "snacks & munchies", "snacks", "munchies":
                matches = normalizedProductCategory.contains("snack") || normalizedProductCategory.contains("munchies")
            default:
                // For any other category, use flexible partial matching
                // Check if either contains the other (more lenient)
                matches = normalizedProductCategory.contains(normalizedCategoryTitle) || 
                         normalizedCategoryTitle.contains(normalizedProductCategory) ||
                         normalizedProductCategory.split(separator: " ").contains(where: { normalizedCategoryTitle.contains($0) }) ||
                         normalizedCategoryTitle.split(separator: " ").contains(where: { normalizedProductCategory.contains($0) })
            }
            
            return matches
        }
        
        print("📦 Category '\(categoryTitle)': Found \(filtered.count) products out of \(homeViewModel.products.count) total")
        return filtered
    }
    
    // Filtered and sorted products
    private var filteredProducts: [Product] {
        var products = categoryProducts
        
        // Apply search filter
        if !searchText.isEmpty {
            products = products.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply price filter
        if selectedFilters.priceRange.upperBound < 1000 {
            products = products.filter { product in
                let price = product.discountPrice ?? product.price
                return price >= selectedFilters.priceRange.lowerBound && price <= selectedFilters.priceRange.upperBound
            }
        }
        
        // Apply discount filter
        if selectedFilters.showDiscountedOnly {
            products = products.filter { $0.discountPrice != nil }
        }
        
        // Apply availability filter
        if selectedFilters.showAvailableOnly {
            products = products.filter { $0.isAvailable }
        }
        
        // Apply sorting
        return sortProducts(products, by: selectedSortOption)
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with search and filters
                headerSection
                
                // Products grid
                productsGridSection
            }
        }
        .navigationTitle(categoryTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Immediate animation without delay for better performance
            withAnimation(.easeOut(duration: 0.3)) {
                animateProducts = true
            }
        }
        .sheet(isPresented: $showingFilter) {
            FilterSheet(selectedFilters: $selectedFilters, isPresented: $showingFilter)
        }
        .sheet(isPresented: $showingSortOptions) {
            SortSheet(selectedSortOption: $selectedSortOption, isPresented: $showingSortOptions)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {  // Reduced spacing for better compactness
            // Item count and actions
            HStack {
                Text("\(filteredProducts.count) items")
                    .font(.system(size: 14, weight: .medium))  // Made weight medium for better visibility
                    .foregroundColor(.black)  // Changed to black for better contrast
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))  // Slightly smaller for better proportion
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search in \(categoryTitle)", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)  // Slightly reduced padding
            .background(Color.white)
            .cornerRadius(10)  // Slightly smaller radius for modern look
            .padding(.horizontal, 16)
            
            // Filter and sort buttons - Improved alignment
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Button(action: { showingFilter = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 16))
                            Text("Filter")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Button(action: { showingSortOptions = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 16))
                            Text("Sort")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
                
                // Delivery time info
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color("primaryGreen"))
                    Text("8-15 mins")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 12)  // Reduced bottom padding
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // MARK: - Products Grid Section
    private var productsGridSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if filteredProducts.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No products found")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Try adjusting your search or filter criteria")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(Array(filteredProducts.enumerated()), id: \.element.id) { index, product in
                        ProductListCard(product: product)
                            .opacity(animateProducts ? 1 : 0)
                            .offset(y: animateProducts ? 0 : 10)
                            .animation(.easeOut(duration: 0.3), value: animateProducts)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16) // Add top padding for spacing from filter/sort line
                .padding(.bottom, 100)
            }
        }
        .padding(.top, 4) // Add padding at the top to create space after the header
    }
    
    // MARK: - Helper Functions
    private func sortProducts(_ products: [Product], by option: SortOption) -> [Product] {
        switch option {
        case .popularity:
            return products.sorted { $0.isFeatured && !$1.isFeatured }
        case .priceLowToHigh:
            return products.sorted { ($0.discountPrice ?? $0.price) < ($1.discountPrice ?? $1.price) }
        case .priceHighToLow:
            return products.sorted { ($0.discountPrice ?? $0.price) > ($1.discountPrice ?? $1.price) }
        case .discount:
            return products.sorted { 
                let discount1 = $0.discountPercentage ?? 0
                let discount2 = $1.discountPercentage ?? 0
                return discount1 > discount2
            }
        case .newest:
            return products // In real app, would sort by date added
        }
    }
}

// MARK: - Supporting Enums and Structs
enum SortOption: String, CaseIterable {
    case popularity = "Popularity"
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    case discount = "Discount"
    case newest = "Newest"
}

struct FilterOptions {
    var priceRange: ClosedRange<Double> = 0...1000
    var showDiscountedOnly: Bool = false
    var showAvailableOnly: Bool = true
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Binding var selectedFilters: FilterOptions
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Price Range
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Range")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack {
                        Text("₹\(Int(selectedFilters.priceRange.lowerBound))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("₹\(Int(selectedFilters.priceRange.upperBound))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    // Custom range slider would go here - simplified for now
                    HStack {
                        Slider(value: Binding(
                            get: { Double(selectedFilters.priceRange.lowerBound) },
                            set: { selectedFilters.priceRange = $0...selectedFilters.priceRange.upperBound }
                        ), in: 0...1000, step: 10)
                    }
                }
                
                // Discount Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Offers")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Toggle("Show only discounted items", isOn: $selectedFilters.showDiscountedOnly)
                        .font(.system(size: 16))
                }
                
                // Availability Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Availability")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Toggle("Show only available items", isOn: $selectedFilters.showAvailableOnly)
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                // Apply Button
                ConsistentButton(
                    title: "Apply Filters",
                    action: {
                        isPresented = false
                    }
                )
            }
            .padding(20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Reset") {
                    selectedFilters = FilterOptions()
                },
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

// MARK: - Sort Sheet
struct SortSheet: View {
    @Binding var selectedSortOption: SortOption
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        selectedSortOption = option
                        isPresented = false
                    }) {
                        HStack {
                            Text(option.rawValue)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if selectedSortOption == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color("primaryYellow"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    if option != SortOption.allCases.last {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

// MARK: - Product List Card
struct ProductListCard: View {
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
            VStack(alignment: .leading, spacing: 8) {  // Reduced spacing for tighter layout
            // Product Image with discount badge - NavigationLink only for image and info
            NavigationLink(destination: ProductDetailView(product: product)) {
                VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)  // Slightly smaller radius
                            .fill(Color.white)
                            .aspectRatio(1, contentMode: .fit)
                        
                        Image(systemName: CategoryIconMap.iconName(for: product.category))
                            .font(.system(size: 44))  // Slightly smaller icon
                            .foregroundColor(CategoryIconMap.colorName(for: product.category))
                    }
                    .frame(height: 130) // Reduced height for better proportions
                    
                    // Discount badge
                    if let discountPercentage = product.discountPercentage {
                        Text("\(discountPercentage)% OFF")
                            .font(.system(size: 9, weight: .bold))  // Slightly smaller text
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color("primaryGreen"))
                            .cornerRadius(3)
                            .padding(6)
                    }
                }
                
                // Delivery time
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color("primaryGreen"))
                    Text("8 MINS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.top, 2) // Reduced spacing after image
                
                // Product name
                Text(product.name)
                    .font(.system(size: 13, weight: .medium))  // Slightly smaller font
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 35, alignment: .top) // Reduced height for tighter layout
                
                // Weight
                Text(product.weight)
                    .font(.system(size: 11))  // Smaller font
                    .foregroundColor(.gray)
                    .padding(.top, -2) // Tighter spacing
                }
            }
            .buttonStyle(PlainButtonStyle())
                
            // Price and Add Button Section - Outside NavigationLink
                HStack(alignment: .center, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                    if let discountPrice = product.discountPrice {
                            HStack(spacing: 4) {
                        Text("₹\(Int(discountPrice))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("₹\(Int(product.price))")
                                    .font(.system(size: 11))
                            .strikethrough()
                            .foregroundColor(.gray)
                            }
                    } else {
                        Text("₹\(Int(product.price))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        }
                    }
                    
                    Spacer()
                    
                    // Enhanced Add Button with Quantity Controls
                    if isInCart && cartQuantity > 0 {
                        // Quantity Controls (like Blinkit)
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
                                    .background(Color("primaryGreen"))
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
                                    .background(Color("primaryGreen"))
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
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(showAddedFeedback ? Color("primaryGreen") : Color("primaryGreen"))
                            )
                            .scaleEffect(addingToCart ? 0.95 : 1.0)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 4)
            }
            .padding(10)  // Reduced internal padding
            .background(Color.white)
            .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)  // Lighter shadow
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.08), lineWidth: 0.5)  // Thinner border
        )
    }
}

// MARK: - Filter View
struct FilterView: View {
    @Binding var filters: FilterOptions
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // Price Range
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Range")
                        .font(.system(size: 16, weight: .medium))
                    
                    HStack {
                        Text("₹\(Int(filters.priceRange.lowerBound))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("₹\(Int(filters.priceRange.upperBound))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Custom range slider would go here
                    // For now, using toggle buttons
                    HStack(spacing: 8) {
                        ForEach([(0.0...100.0, "Under ₹100"), (100.0...500.0, "₹100-500"), (500.0...1000.0, "₹500+")], id: \.1) { range, title in
                            Button(action: {
                                filters.priceRange = range
                            }) {
                                Text(title)
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(filters.priceRange == range ? Color("primaryYellow") : Color.gray.opacity(0.2))
                                    .foregroundColor(filters.priceRange == range ? .black : .black)
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                
                // Other filters
                VStack(alignment: .leading, spacing: 16) {
                    Toggle("Show only discounted items", isOn: $filters.showDiscountedOnly)
                        .font(.system(size: 14))
                    
                    Toggle("Show only available items", isOn: $filters.showAvailableOnly)
                        .font(.system(size: 14))
                }
                
                Spacer()
                
                // Apply button
                ConsistentButton.primary(
                    title: "Apply Filters",
                    action: { dismiss() },
                    isEnabled: true
                )
                .frame(maxWidth: .infinity)
            }
            .padding(20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        filters = FilterOptions()
                    }
                }
            }
        }
    }
}

// MARK: - Sort Options View
struct SortOptionsView: View {
    @Binding var selectedOption: SortOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        dismiss()
                    }) {
                        HStack {
                            Text(option.rawValue)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if selectedOption == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("primaryYellow"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(Color.white)
                    
                    if option != SortOption.allCases.last {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Sort by")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(400)])
    }
}

// Note: All products now loaded from Firestore via HomeViewModel
// No more hardcoded sample data needed

#Preview {
    ProductListView(categoryTitle: "Cookies & Biscuits", categoryType: "banner")
        .environmentObject(CartViewModel())
        .environmentObject(HomeViewModel())
} 