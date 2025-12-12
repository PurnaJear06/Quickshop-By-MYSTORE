import SwiftUI
import UIKit

struct KidsView: View {
    // Environment objects for shared state
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // Namespace for matched geometry effects
    @Namespace private var animation
    
    // State for animations and transitions
    @State private var scrollOffset: CGFloat = 0
    @State private var animateContent = false
    @State private var isAppearing = true
    @State private var addingToCartItems: [String: Bool] = [:]
    @State private var selectedSubcategory: String? = nil
    @State private var showBackToTop = false
    @State private var showingLocationPicker = false
    @State private var showingSearch = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // ABSOLUTE BACKGROUND - Banner Image
                Image("kids_page_banner")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                    .edgesIgnoringSafeArea(.all)
                    .position(x: geometry.size.width/2, y: geometry.size.height * 0.35)
                
                // Main content laid on top of banner
                ScrollView {
                    // ScrollOffset tracker
                    GeometryReader { proxy in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("kidsScroll")).minY)
                    }
                    .frame(height: 0)
                    
                    VStack(spacing: 0) {
                        // Status bar area
                        Color.clear
                            .frame(height: getTopSafeAreaInset())
                        
                        // Delivery Info Bar - aligned consistently with HomeView
                        VStack(alignment: .leading, spacing: 2) {
                            Text("QuickShop in")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            
                            HStack(alignment: .top) {
                                // Delivery time and location
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(DeliveryService.shared.estimatedDeliveryTime) minutes")
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
                                
                                // Wallet button on right side - matching HomeView (without rupee symbol)
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Image(systemName: "wallet.pass")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.black)
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 10)
                        
                        // Search bar
                        HStack {
                            Button(action: {
                                showingSearch = true
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                    
                                    Text("Search \"kids products\"")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.gray)
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
                        
                        // Category tabs - improved spacing to match HomeView
                        categoryTabsSection
                        
                        // Category cards section (horizontal scroll) - standardized sizing
                        categoryCardsSection
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                        
                        // Content section using KidsContentView
                        KidsContentView()
                            .environmentObject(cartViewModel)
                            .environmentObject(homeViewModel)
                    }
                }
                .coordinateSpace(name: "kidsScroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                    showBackToTop = value < -150
                }
                .edgesIgnoringSafeArea(.top)
                
                // "Back to top" button - only shown when scrolled down
                if showBackToTop {
                    VStack {
                        Spacer()
                            .frame(height: 300)
                        
                        Button(action: {
                            withAnimation {
                                // Scroll back to top
                                scrollOffset = 0
                                showBackToTop = false
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
                }
            }
        }
        .background(Color.clear)
        .opacity(isAppearing ? 1 : 0)
        .scaleEffect(isAppearing ? 1 : 0.95)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isAppearing = true
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                animateContent = true
            }
        }
        .onDisappear {
            isAppearing = false
            animateContent = false
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.all, edges: .top) // Critical to extend behind status bar
        .sheet(isPresented: $showingLocationPicker) {
            AddressListView(isPresented: $showingLocationPicker)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView()
        }
    }
    
    // MARK: - Category Tabs Section - Standardized
    private var categoryTabsSection: some View {
        let categories = ["All", "Summer", "Grocery", "Beauty", "Kids"]
        let icons = ["square.grid.2x2.fill", "vacations", "food", "make-up", "playing"]
        let useSystemIcons = [true, false, false, false, false]
        let colors = [Color.orange, Color.yellow, Color.purple, Color.pink, Color.green]

        return GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(categories.indices, id: \.self) { index in
                        CategoryTabView(
                            title: categories[index],
                            icon: icons[index],
                            color: colors[index],
                            isSelected: categories[index] == "Kids",
                            isKidsMode: true,
                            isSystemIcon: useSystemIcons[index],
                            animation: animation
                        ) {
                            if categories[index] != "Kids" {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    isAppearing = false
                                    animateContent = false
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    homeViewModel.selectCategory(categories[index])
                                }
                            }
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
    
    // MARK: - Category Tab View Helper - Standardized
    struct CategoryTabView: View {
        let title: String
        let icon: String
        let color: Color
        let isSelected: Bool
        let isKidsMode: Bool
        let isSystemIcon: Bool
        let animation: Namespace.ID
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(color.opacity(0.2))
                                .frame(width: 36, height: 36)
                                .matchedGeometryEffect(id: "selectedBackground", in: animation)
                            
                            if isSystemIcon {
                                Image(systemName: icon)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(color)
                            } else {
                                Image(icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(color)
                            }
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 36, height: 36)
                            
                            if isSystemIcon {
                                Image(systemName: icon)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                            } else {
                                Image(icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    Text(title)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .black : .black)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
          // MARK: - Category Cards Section - Standardized sizing to match GroceryView
    private var categoryCardsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                // Toys Card
                categoryBannerCard(image: "kids_banner_2", title: "Himalayan Products")
                
                // Baby Care Card
                categoryBannerCard(image: "kids_banner_1", title: "Jhonson & Jhonson")
                
                // Educational Card
                categoryBannerCard(image: "kids_banner_3", title: "Feeding items")
                
                // Games Card
                categoryBannerCard(image: "kids_banner_4", title: "Dipers & Wipes")
            }
            .padding(.horizontal, 16)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
          // Category card for horizontal scrolling section - standardized to match GroceryView
    private func categoryBannerCard(image: String, title: String) -> some View {
        NavigationLink(destination: ProductListView(categoryTitle: title, categoryType: "banner")) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 120, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "3366FF"), lineWidth: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    )
                
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Extensions
extension KidsView {
    func getTopSafeAreaInset() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        
        return keyWindow?.safeAreaInsets.top ?? 44
    }
}

// MARK: - Previews
struct KidsView_Previews: PreviewProvider {
    static var previews: some View {
        KidsView()
            .environmentObject(CartViewModel())
            .environmentObject(HomeViewModel())
    }
} 