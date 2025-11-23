import SwiftUI

struct HomeView: View {
    // Environment objects
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    
    // State
    @State private var showingSearch = false
    @State private var showingLocationPicker = false
    @State private var bannerIndex = 0
    @State private var showBackToTop = false
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedCategory: String? = "All"
    @State private var animatedSelection: String? = "All"
    @State private var animateCategoryCards = false
    @State private var currentBannerDragOffset: CGFloat = 0
    @State private var bannerDraggedSize: CGSize = .zero
    @State private var previousBannerIndex: Int = 0
    @State private var isAutoScrolling: Bool = true
    @State private var totalBanners: Int = 4
    
    // Modern animation states
    @State private var transitionInProgress = false
    @State private var categoryTapAnimation = false
    @State private var selectedCategoryScale: CGFloat = 1.0
    @State private var pageTransitionOffset: CGFloat = 0
    @Namespace private var categoryTransitionID
    
    // Animation timing
    let bannerTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient that changes based on category
                categoryBackgroundGradient
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 0.6), value: selectedCategory)
                
                Group {
                            if selectedCategory == "Summer" {
                        // Modern transition for Summer category
                SummerView()
                    .environmentObject(cartViewModel)
                    .environmentObject(homeViewModel)
                            .modifier(ModernPageTransition(
                                isVisible: selectedCategory == "Summer",
                                transitionID: categoryTransitionID,
                                categoryColor: .yellow,
                                animationNamespace: categoryTransitionID
                            ))
            } else if selectedCategory == "Grocery" {
                        // Modern transition for Grocery category
                GroceryView()
                    .environmentObject(cartViewModel)
                    .environmentObject(homeViewModel)
                            .modifier(ModernPageTransition(
                                isVisible: selectedCategory == "Grocery",
                                transitionID: categoryTransitionID,
                                categoryColor: .purple,
                                animationNamespace: categoryTransitionID
                            ))
            } else if selectedCategory == "Beauty" {
                        // Modern transition for Beauty category
                BeautyView()
                    .environmentObject(cartViewModel)
                    .environmentObject(homeViewModel)
                            .modifier(ModernPageTransition(
                                isVisible: selectedCategory == "Beauty",
                                transitionID: categoryTransitionID,
                                categoryColor: .pink,
                                animationNamespace: categoryTransitionID
                            ))
            } else if selectedCategory == "Kids" {
                        // Modern transition for Kids category
                KidsView()
                    .environmentObject(cartViewModel)
                    .environmentObject(homeViewModel)
                            .modifier(ModernPageTransition(
                                isVisible: selectedCategory == "Kids",
                                transitionID: categoryTransitionID,
                                categoryColor: .green,
                                animationNamespace: categoryTransitionID
                            ))
            } else {
                        // Main home content with modern animations
                        mainHomeContent(geometry: geometry)
                            .modifier(ModernPageTransition(
                                isVisible: selectedCategory == "All" || selectedCategory == nil,
                                transitionID: categoryTransitionID,
                                categoryColor: .orange,
                                animationNamespace: categoryTransitionID
                            ))
                    }
                }
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(isPresented: $showingLocationPicker)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView()
        }
        .navigationBarHidden(true)
        .onReceive(bannerTimer) { _ in
            guard isAutoScrolling else { return }
            withAnimation(.easeInOut(duration: 0.8)) {
                bannerIndex = (bannerIndex + 1) % totalBanners
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
            withAnimation(.easeOut(duration: 0.2)) {
                showBackToTop = value < -300
            }
        }
        .onAppear {
            if selectedCategory == nil {
                selectedCategory = "All"
            }
            animatedSelection = selectedCategory
            if selectedCategory == "Summer" {
                homeViewModel.selectCategory("Summer")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateCategoryCards = true
                }
            }
        }
        .onChange(of: homeViewModel.selectedCategory) { oldValue, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                selectedCategory = newValue
                animatedSelection = newValue
            }
        }
    }
    
    // MARK: - Modern Background Gradient
    private var categoryBackgroundGradient: some View {
                    LinearGradient(
            colors: backgroundColorsForCategory(selectedCategory ?? "All"),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func backgroundColorsForCategory(_ category: String) -> [Color] {
        switch category {
        case "Summer":
            return [Color(hex: "FFE4B5"), Color(hex: "FFA500")]
        case "Beauty":
            return [Color(hex: "FFE4E1"), Color(hex: "FFC0CB")]
        case "Grocery":
            return [Color(hex: "E6E6FA"), Color(hex: "DDA0DD")]
        case "Kids":
            return [Color(hex: "E0FFE0"), Color(hex: "98FB98")]
        default:
            return [Color(hex: "FFF9D1"), Color(hex: "FFE58F")]
        }
    }
    
    // MARK: - Main Home Content
    private func mainHomeContent(geometry: GeometryProxy) -> some View {
                    VStack(spacing: 0) {
                        // Content - same structure for all pages
                        ScrollView {
                            GeometryReader { proxy in
                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                            }
                            .frame(height: 0)

                            VStack(spacing: 0) {
                                // Delivery Info Bar - consistent across all pages
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("QuickShop in")
                                        .font(.system(size: 15))
                                        .foregroundColor(.black)
                                    
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("9 minutes")
                                                .font(.system(size: 34, weight: .bold))
                                                .foregroundColor(.black)
                                            
                                            Button(action: {
                                                showingLocationPicker = true
                                            }) {
                                                HStack(spacing: 3) {
                                                    Text("HOME -")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.black.opacity(0.8))
                                                    
                                                    Text("Purna, TechNext PG")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.black.opacity(0.8))
                                                        .lineLimit(1)
                                                    
                                                    Image(systemName: "chevron.down")
                                                        .font(.caption2)
                                                        .foregroundColor(.black.opacity(0.8))
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 42, height: 42)
                                            .overlay(
                                                Image(systemName: "wallet.pass")
                                                    .font(.system(size: 20, weight: .medium))
                                                    .foregroundColor(Color("secondaryOrange"))
                                            )
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 10)

                                // Search and categories section - consistent layout
                                VStack(spacing: 0) {
                                    // Search bar
                                    HStack {
                                        Button(action: {
                                            showingSearch = true
                                        }) {
                                            HStack {
                                                Image(systemName: "magnifyingglass")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(Color.black.opacity(0.6))
                                                    .padding(.trailing, 8)
                                                
                                                Text("Search \"ice cream\"")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color.black.opacity(0.6))
                                                
                                                Spacer()
                                                
                                                Image(systemName: "mic.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(Color.black.opacity(0.6))
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                    .padding(.bottom, 12)

                        // Modern Categories section
                        modernCategoriesSection
                                }
                                .background(Color(hex: "FFF9D1"))

                                // Main content area
                                if selectedCategory == "Decor" {
                                    DecorContentView()
                                        .environmentObject(cartViewModel)
                                        .environmentObject(homeViewModel)
                            .modifier(ContentFadeInTransition())
                                        .edgesIgnoringSafeArea(.all)
                                } else if selectedCategory == "Kids" {
                                    KidsContentView()
                                       .environmentObject(cartViewModel)
                                       .environmentObject(homeViewModel)
                           .modifier(ContentFadeInTransition())
                                       .padding(.top, 20)
                                } else { // "All" or default content
                                    VStack(spacing: 0) {
                                        newBannerSection
                                            .padding(.top, 15)
                                        newCategoryCardsRow
                                            .padding(.top, 20)
                                        if userViewModel.isLoggedIn {
                                            previouslyBoughtSection
                                                .padding(.top, 16)
                                        }
                                        productCategoriesGrid
                                            .padding(.top, 16)
                                            .padding(.bottom, 20)
                                    }
                                    .background(Color(hex: "FFF9D1"))
                        .modifier(StaggeredContentTransition())
                                }
                            }
                        }
                    }
        .overlay(
                    // "Back to top" button - only shown for non-Summer views
            backToTopButton,
            alignment: .bottom
        )
    }
    
    private var backToTopButton: some View {
        Group {
                    if showBackToTop && (selectedCategory == "All" || selectedCategory == nil) {
                        VStack {
                            Spacer()
                                .frame(height: 300)

                            Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    scrollOffset = 0
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 16, weight: .semibold))

                                    Text("Back to top")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color("primaryYellow"))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                            }
                            Spacer()
                        }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
    }
    
    // MARK: - Banner Section
    private var newBannerSection: some View {
        VStack(spacing: 16) {
                    ZStack {
                        TabView(selection: $bannerIndex) {
                            // Banner 1 - New Primary Banner
                            BannerItemView(image: "summer_banner4")
                                .tag(0)
                            
                            // Banner 2 - Summer Banner (previously first)
                            BannerItemView(image: "summer_banner")
                                .tag(1)
                            
                            // Banner 3 - Modified to match banner 1 style
                            BannerItemView(image: "summer_banner4")
                                .tag(2)
                            
                            // Banner 4 - Third Summer Banner (previously third)
                            BannerItemView(image: "summer_banner3")
                                .tag(3)
                        }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 200)
                .cornerRadius(12)
                        .padding(.horizontal, 16)
            }
            
            // Custom page indicators
            HStack(spacing: 8) {
                ForEach(0..<totalBanners, id: \.self) { index in
                    Circle()
                        .fill(index == bannerIndex ? Color("primaryYellow") : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == bannerIndex ? 1.2 : 1.0)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: bannerIndex)
        }
    }
    
    // MARK: - Product Categories Grid (Featured Products)
    private var productCategoriesGrid: some View {
        let categories = [
            "Vegetables & Fruits",
            "Dairy & Breakfast",
            "Munchies",
            "Cold Drinks & Juices",
            "Instant & Frozen Food",
            "Tea, Coffee & Health Drink",
            "Bakery & Biscuits",
            "Sweet Tooth",
            "Atta, Rice & Dal",
            "Masala, Oil & More",
            "Chicken, Meat & Fish",
            "Pan Corner",
            "Organic & Healthy Living",
            "Baby Care",
            "Pharma & Wellness",
            "Cleaning & Household",
            "Home & Office",
            "Personal Care",
            "Pet Care"
        ]
        
        // Two-column card grid to match target design
        let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(getCategoryTitle())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("textGray"))
                Spacer()
                Button(action: {
                    // Navigate to a generic product list for all featured categories
                }) {
                    HStack(spacing: 6) {
                        Text("See all products")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color("primaryYellow"))
                }
            }
            .padding(.horizontal, 16)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(categories, id: \.self) { title in
                    featuredCategoryCard(title: title, count: Int.random(in: 5...90))
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func getCategoryTitle() -> String {
        switch selectedCategory {
        case "Summer":
            return "Summer Special"
        case "Grocery":
            return "Grocery Essentials"
        case "Beauty":
            return "Beauty & Care"
        case "Kids":
            return "Kids Products"
        default:
            return "Featured Products"
        }
    }
    
    // New featured card cell to match the reference design
    private func featuredCategoryCard(title: String, count: Int) -> some View {
        NavigationLink(destination: ProductListView(categoryTitle: title, categoryType: "category")) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.08), lineWidth: 0.5)
                        )
                        .frame(height: 170)
                        .overlay(
                            VStack(spacing: 10) {
                                HStack(spacing: 10) {
                                    smallIconBox(for: title)
                                    smallIconBox(for: title)
                                }
                                HStack(spacing: 10) {
                                    smallIconBox(for: title)
                                    smallIconBox(for: title)
                                }
                            }
                            .padding(14)
                        )
                    Text("+\(count) more")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        )
                        .padding(8)
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("textGray"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func smallIconBox(for categoryTitle: String) -> some View {
        let iconName = CategoryIconMap.iconName(for: categoryTitle)
        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.08))
                .frame(width: 72, height: 72)
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.gray)
        }
    }
    
    // Previously Bought Section
    private var previouslyBoughtSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Previously bought")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
                .foregroundColor(Color("textGray"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(homeViewModel.recentProducts) { product in
                        productBoughtItem(product: product)
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: {}) {
                HStack {
                    Text("See all products")
                        .font(.footnote)
                        .foregroundColor(Color("primaryYellow"))
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Color("primaryYellow"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 5)
        }
        .padding(.vertical, 10)
    }
    
    private func productBoughtItem(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            ZStack(alignment: .topLeading) {
                Image(systemName: CategoryIconMap.iconName(for: product.category))
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                if product.name.contains("Peanut") {
                    Text("Trending")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color("secondaryOrange"))
                        .cornerRadius(8)
                        .offset(x: 5, y: 5)
                }
            }
            
            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(product.weight)
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Text(product.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .frame(height: 30)
                    .foregroundColor(Color("textGray"))
                
                // Rating
                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < 4 ? "star.fill" : "star.leadinghalf.filled")
                            .font(.system(size: 8))
                            .foregroundColor(Color("secondaryOrange"))
                    }
                    
                    Text("(\(Int.random(in: 300...400)))")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
                
                // Delivery Time
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 8))
                        .foregroundColor(Color("primaryYellow"))
                    
                    Text("13 MINS")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                // Price
                Text("₹\(Int(product.price))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("textGray"))
                
                // Enhanced Add Button with Quantity Controls
                EnhancedAddButtonForBoughtItems(product: product)
                
                // See more like this link
                Button(action: {
                    // Navigate to similar products
                }) {
                    Text("See more like this")
                        .font(.caption2)
                        .foregroundColor(Color("primaryYellow"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .frame(width: 160)
    }
    
    // MARK: - Modern Categories Section with Enhanced Animations
    private var modernCategoriesSection: some View {
        let categories = ["All", "Summer", "Grocery", "Beauty", "Kids"]
        let icons = ["square.grid.2x2.fill", "vacations", "food", "make-up", "playing"]
        let useSystemIcons = [true, false, false, false, false]
        let colors = [Color.orange, Color.yellow, Color.purple, Color.pink, Color.green]

        return GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(categories.indices, id: \.self) { index in
                        ModernCategoryTabView(
                            title: categories[index],
                            icon: icons[index],
                            color: colors[index],
                            isSelected: animatedSelection == categories[index],
                            isSummerMode: selectedCategory == "Summer",
                            isSystemIcon: useSystemIcons[index],
                            animationNamespace: categoryTransitionID
                        ) {
                            performCategorySelection(categories[index])
                        }
                        .frame(width: max(geometry.size.width / CGFloat(categories.count), 1))
                    }
                }
                .frame(minWidth: geometry.size.width)
            }
            .padding(.vertical, 8)
        }
        .frame(height: 60)
    }
    
    // MARK: - Category Selection with Modern Animations
    private func performCategorySelection(_ category: String) {
        // Don't animate if already selected
        guard category != selectedCategory else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1)) {
            transitionInProgress = true
            categoryTapAnimation = true
            selectedCategoryScale = 1.15
        }
        
        // First phase: Category icon animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedCategory = category
                animatedSelection = category
                homeViewModel.selectCategory(category)
            }
        }
        
        // Second phase: Scale back and complete transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedCategoryScale = 1.0
                categoryTapAnimation = false
                transitionInProgress = false
            }
        }
    }
    
    // NEW: Category Cards Row
    private var newCategoryCardsRow: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Category banner cards
                    newCategoryBannerCard(
                        image: "banner_1",
                        title: "Snacks & Munchies"
                    )
                    
                    newCategoryBannerCard(
                        image: "banner_2",
                        title: "Mangoes & Melons"
                    )
                    
                    newCategoryBannerCard(
                        image: "banner_3",
                        title: "Summer Care"
                    )
                    
                    newCategoryBannerCard(
                        image: "banner_4",
                        title: "Home Essentials"
                    )
                    
                    newCategoryBannerCard(
                        image: "banner_5",
                        title: "Fresh Produce"
                    )
                }
                .padding(.horizontal, 16)
            }
        }
        .opacity(animateCategoryCards ? 1 : 0)
        .offset(y: animateCategoryCards ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateCategoryCards = true
            }
        }
    }
    
    // NEW: Helper function for category banner cards with appearance animations
    private func newCategoryBannerCard(image: String, title: String) -> some View {
        NavigationLink(destination: ProductListView(categoryTitle: title, categoryType: "banner")) {
            ZStack {
                // Special case for banner_3 (Summer Treats) to make the title visible
                if image == "banner_3" {
                    // No white background, just the image with border
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 160)
                        .offset(y: 11) // Adjusted to eliminate the small gap
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "3366FF"), lineWidth: 1)
                        )
                } else {
                    // Card with curved corners and blue border
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(width: 120, height: 160)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "3366FF"), lineWidth: 1)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                    
                    // Background image that fills the entire card
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // Delivery Info Bar
    private var deliveryInfoBar: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("QuickShop in")
                .font(.system(size: 15))
                .foregroundColor(.black)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("9 minutes")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                    
                    // Delivery address - Tappable
                    Button(action: {
                        showingLocationPicker = true
                    }) {
                        HStack(spacing: 3) {
                            Text("HOME -")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black.opacity(0.8))
                            
                            Text("Purna, TechNext PG")
                                .font(.system(size: 12))
                                .foregroundColor(.black.opacity(0.8))
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(.black.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                // Right header - only wallet button (removed profile)
                Circle()
                    .fill(Color.white)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color("secondaryOrange"))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8) // Reduced top padding
        .padding(.bottom, 10) // Reduced bottom padding
    }
    
    // Search Bar
    private var searchBar: some View {
        HStack {
            Button(action: {
                showingSearch = true
            }) {
                HStack {
                    // Magnifying glass icon
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black.opacity(0.6))
                        .padding(.trailing, 8)
                    
                    // Search text
                    Text("Search \"ice cream\"")
                        .font(.system(size: 16))
                        .foregroundColor(Color.black.opacity(0.6))
                    
                    Spacer()
                    
                    // Mic icon
                    Image(systemName: "mic.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.black.opacity(0.6))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingSearch) {
            SearchView()
        }
    }
}

// Location Picker View with updated colors and improved alignment
struct LocationPickerView: View {
    @Binding var isPresented: Bool
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button and title
            VStack(spacing: 4) {
                HStack {
                    // Back button
                    Button(action: { isPresented = false }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .padding(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                
                // Title
                Text("Select delivery location")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .padding(.top, 12)
            .background(Color.white)
            
            // Search area box
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
                
                TextField("Search for area, street name...", text: $searchText)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
            }
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            
            // Location options
            ScrollView {
                VStack(spacing: 0) {
                    // Use current location
                    locationOption(
                        icon: "location.fill",
                        title: "Use your current location",
                        iconColor: Color("primaryYellow")
                    )
                    
                    Divider().padding(.leading, 60)
                    
                    // Add new address
                    locationOption(
                        icon: "plus",
                        title: "Add new address",
                        iconColor: Color("primaryYellow")
                    )
                    
                    Divider().padding(.leading, 60)
                    
                    // Request address
                    locationOption(
                        icon: "message.fill",
                        title: "Request address from someone else",
                        iconColor: Color("primaryYellow")
                    )
                    
                    Divider()
                    
                    // Your saved addresses section
                    HStack {
                        Text("Your saved addresses")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    
                    // Saved address 1
                    savedAddressItem(
                        title: "Home",
                        distance: "334.98 km away",
                        address: "Side to road, Opp. Pizza Hut, Gopalapātnam, Simhachalam, Visakhapatnam"
                    )
                    
                    Divider()
                    
                    // Saved address 2
                    savedAddressItem(
                        title: "Home", 
                        distance: "499.22 km away",
                        address: "Rithika, TechNext PG, 6 Floor, Opp velocity block, TechNext Women PG, opp. Prestige, Kariyammana Agrahara, Bellandur, Bengaluru"
                    )
                }
                .background(Color.white)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func locationOption(icon: String, title: String, iconColor: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16))
            }
            .padding(.leading, 16)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .padding(.trailing, 16)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle selection
        }
    }
    
    private func savedAddressItem(title: String, distance: String, address: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 16) {
                // Home icon
                ZStack {
                    Circle()
                        .fill(Color("secondaryOrange").opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "house.fill")
                        .foregroundColor(Color("secondaryOrange"))
                        .font(.system(size: 16))
                }
                .padding(.leading, 16)
                .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(distance)
                            .font(.subheadline)
                            .foregroundColor(Color("primaryYellow"))
                    }
                    
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.trailing, 16)
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                // Menu and share buttons
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(Color("primaryYellow"))
                        .padding(8)
                        .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                .padding(.leading, 8)
                .padding(.trailing, 16)
            }
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .contentShape(Rectangle())
        .onTapGesture {
            isPresented = false
        }
    }
}

// MARK: - Banner Item View
struct BannerItemView: View {
    let image: String
    
    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
    }
}

// MARK: - Modern Animation View Modifiers
struct ModernPageTransition: ViewModifier {
    let isVisible: Bool
    let transitionID: Namespace.ID
    let categoryColor: Color
    let animationNamespace: Namespace.ID
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 50
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : scale)
            .opacity(isVisible ? 1.0 : opacity)
            .offset(y: isVisible ? 0 : yOffset)
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.1), value: isVisible)
            .onAppear {
                if isVisible {
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                        scale = 1.0
                        opacity = 1.0
                        yOffset = 0
                    }
                }
            }
            .onChange(of: isVisible) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                        scale = 1.0
                        opacity = 1.0
                        yOffset = 0
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scale = 0.95
                        opacity = 0
                        yOffset = -20
                    }
                }
            }
    }
}

struct ContentFadeInTransition: ViewModifier {
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 30
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                    opacity = 1.0
                    yOffset = 0
                }
            }
    }
}

struct StaggeredContentTransition: ViewModifier {
    @State private var animateElements = false
    
    func body(content: Content) -> some View {
        content
            .opacity(animateElements ? 1 : 0)
            .offset(y: animateElements ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    animateElements = true
                }
            }
    }
}

// MARK: - Modern Category Tab View Component
struct ModernCategoryTabView: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let isSummerMode: Bool
    let isSystemIcon: Bool
    let animationNamespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "selectedBackground", in: animationNamespace)
                    }
                    
                    if isSystemIcon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isSelected ? color : .gray)
                    } else {
                        Image(icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isSelected ? color : .gray)
                    }
                }
                .scaleEffect(isSelected ? 1.1 : (isPressed ? 0.95 : 1.0))
                
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? color : .gray)
                    .multilineTextAlignment(.center)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(UserViewModel())
} 

// MARK: - Enhanced Add Button for Bought Items
struct EnhancedAddButtonForBoughtItems: View {
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
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color("primaryRed"))
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
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color("primaryRed"))
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
                
                cartViewModel.addToCart(product: product, quantity: 1)
                
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
                    
                    Text(showAddedFeedback ? "ADDED" : "ADD")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(showAddedFeedback ? Color("primaryGreen") : Color("primaryYellow"))
                )
                .scaleEffect(addingToCart ? 0.95 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
} 
 
