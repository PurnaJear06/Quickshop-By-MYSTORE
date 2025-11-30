import SwiftUI

struct CartView: View {
    // Environment objects
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // State
    @State private var showingCheckout = false
    @State private var selectedPaymentMethod: PaymentMethod = .cashOnDelivery
    @State private var selectedAddress: Address?
    @State private var selectedTipAmount: Int? = nil
    @State private var showingDetailedBill = false
    @State private var showingCustomTip = false
    @State private var customTipInput: String = ""
    
    private let tipOptions = [10, 20, 30]
    private let defaultTipOption = 20
    
    // Total savings calculation
    private var totalSavings: Double {
        return cartViewModel.cartItems.reduce(0.0) { total, item in
            if let mrp = item.product.mrp {
                return total + ((mrp - item.product.price) * Double(item.quantity))
            }
            return total
        }
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            if cartViewModel.cartItems.isEmpty {
                // Empty Cart View with Trending Items
                ScrollView {
                    VStack(spacing: 24) {
                        // Empty Cart Message
                        VStack(spacing: 16) {
                            Image(systemName: "cart")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("Your cart is empty")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Add items to get started")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            ConsistentButton.secondary(
                                title: "Start Shopping",
                                action: {
                                    goToTab(0)
                                }
                            )
                            .frame(width: 180, height: 44)
                        }
                        .padding(.top, 40)
                        
                        // Trending Items Section
                        if !homeViewModel.products.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Trending Products")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(Array(homeViewModel.products.filter { $0.isFeatured }.prefix(6)), id: \.id) { product in
                                        EmptyCartProductCard(product: product)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            } else {
                // Enhanced Cart Items View with modern layout
                VStack(spacing: 0) {
                    // Header with gradient background like Blinkit
                    headerView
                    
                    // Cart Content
                    ScrollView {
                        VStack(spacing: 16) {
                            // Savings banner
                            if totalSavings > 0 {
                                savingsBanner
                            }
                            
                            // Cart Items
                            cartItemsSection
                            
                            // Tipping Section like Swiggy/Blinkit
                            tippingSection
                            
                            // Promo Code Section
                            promoCodeSection
                            
                            // Bill Details Section
                            billDetailsSection
                            
                            // Cancellation Policy Note
                            cancellationPolicySection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // Space for checkout button
                    }
                    
                    // Fixed Checkout Button Container
                    checkoutButtonSection
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCheckout) {
            CheckoutView(
                selectedAddress: $selectedAddress,
                selectedPaymentMethod: $selectedPaymentMethod
            )
        }
        .sheet(isPresented: $showingDetailedBill) {
            DetailedBillView(cartViewModel: cartViewModel, selectedTipAmount: selectedTipAmount)
        }
        .sheet(isPresented: $showingCustomTip) {
            CustomTipSheet(selectedTipAmount: $selectedTipAmount, inputText: $customTipInput, isPresented: $showingCustomTip)
        }
    }
    
    // MARK: - Header View (Instamart Style)
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    goToTab(0)
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                Text("Your Cart")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Share button
                Button(action: {
                    // Share functionality would go here
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
        }
    }
    
    // MARK: - Savings Banner (Refined)
    private var savingsBanner: some View {
        HStack(spacing: 0) {
            Spacer()
            Text("You are saving ₹\(Int(totalSavings)) on this order!")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("primaryGreen").opacity(0.90))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - Cart Items Section
    private var cartItemsSection: some View {
        VStack(spacing: 8) {
            ForEach(cartViewModel.cartItems, id: \.id) { item in
                CartItemRow(item: item, cartViewModel: cartViewModel)
                    .transition(.asymmetric(
                        insertion: .slide.combined(with: .opacity),
                        removal: .slide.combined(with: .opacity)
                    ))
            }
        }
    }
    
    // MARK: - Tipping Section (Compact)
    private var tippingSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Say thanks with a tip")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            
            Text("Show appreciation for their hard work")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                ForEach(tipOptions, id: \.self) { amount in
                    Button(action: {
                        selectedTipAmount = amount
                    }) {
                        VStack(spacing: 4) {
                            Text("₹\(amount)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(selectedTipAmount == amount ? .white : .black)
                            
                            if amount == defaultTipOption {
                                Text("Most tipped")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(selectedTipAmount == amount ? .white.opacity(0.9) : .blue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selectedTipAmount == amount ? Color.blue : Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedTipAmount == amount ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1.5)
                        )
                    }
                }
                
                let isCustom = selectedTipAmount != nil && !tipOptions.contains(selectedTipAmount!)
                Button(action: {
                    customTipInput = isCustom ? String(selectedTipAmount!) : ""
                    showingCustomTip = true
                }) {
                    VStack(spacing: 4) {
                        Text(isCustom ? "₹\(selectedTipAmount!)" : "Other")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isCustom ? .white : .black)
                        if isCustom {
                            Text("Custom")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isCustom ? Color.blue : Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isCustom ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1.5)
                    )
                }
            }
            
            // Optional tip skip button
            if selectedTipAmount != nil {
                Button(action: {
                    selectedTipAmount = nil
                }) {
                    Text("Skip tip")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - Promo Code Section
    private var promoCodeSection: some View {
        VStack(spacing: 16) {
            Text("Have a promo code?")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                TextField("Enter promo code", text: $cartViewModel.promoCode)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .disabled(cartViewModel.isPromoApplied)
                
                Button(action: {
                    if cartViewModel.isPromoApplied {
                        cartViewModel.removePromoCode()
                    } else {
                        cartViewModel.applyPromoCode()
                    }
                }) {
                    Text(cartViewModel.isPromoApplied ? "Remove" : "Apply")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 80)
                        .padding(.vertical, 14)
                        .background(Color("primaryBlue"))
                        .cornerRadius(8)
                }
                .disabled(cartViewModel.promoCode.isEmpty && !cartViewModel.isPromoApplied)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // MARK: - Bill Details Section (Refined)
    private var billDetailsSection: some View {
        VStack(spacing: 14) {
            Text("Bill Details")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 14) {
                billRow(title: "Item Total", value: cartViewModel.subtotal, originalValue: nil)
                
                HStack {
                    Text("Delivery Partner Fee")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("₹25.00")
                        .font(.system(size: 14))
                        .strikethrough()
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color("primaryGreen"))
                        Text("Free")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("primaryGreen"))
                    }
                }
                
                if selectedTipAmount != nil {
                    billRow(title: "Delivery Tip", value: Double(selectedTipAmount!), originalValue: nil)
                }
                
                billRow(title: "Taxes & Charges", value: cartViewModel.gst, originalValue: nil)
            }
            
            Divider()
                .padding(.vertical, 6)
            
            HStack {
                Text("To Pay")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                let totalWithTip = cartViewModel.total + Double(selectedTipAmount ?? 0)
                Text("₹\(totalWithTip, specifier: "%.0f")")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 1)
    }
    
    // MARK: - Helper for Bill Row
    private func billRow(title: String, value: Double, originalValue: Double?) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let original = originalValue {
                Text("₹\(original, specifier: "%.2f")")
                    .font(.system(size: 14))
                    .strikethrough()
                    .foregroundColor(.gray)
                    .padding(.trailing, 6)
            }
            
            Text("₹\(value, specifier: "%.2f")")
                .font(.system(size: 14))
        }
    }
    
    // MARK: - Cancellation Policy Section (Refined)
    private var cancellationPolicySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("NOTE:")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.red)
            
            Text("Orders cannot be cancelled and are non-refundable once packed for delivery.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                // Show cancellation policy
            }) {
                Text("Read cancellation policy")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("primaryBlue"))
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - Checkout Button Section (Refined)
    private var checkoutButtonSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 1)
            
            VStack(spacing: 0) {
                Button(action: {
                    if userViewModel.isLoggedIn {
                        if let defaultAddress = userViewModel.currentUser?.addresses.first(where: { $0.isDefault }) {
                            selectedAddress = defaultAddress
                            showingCheckout = true
                        } else {
                            showingCheckout = true
                        }
                    } else {
                        goToTab(3)
                    }
                }) {
                    HStack {
                        Spacer()
                        let totalWithTip = cartViewModel.total + Double(selectedTipAmount ?? 0)
                        Text(userViewModel.isLoggedIn ? "Proceed to Pay ₹\(Int(totalWithTip))" : "Login to Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("primaryGreen").opacity(0.95))
                    )
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 14)
            .padding(.bottom, max(14, UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.safeAreaInsets.bottom ?? 14))
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: -1)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = cartViewModel.cartItems[index]
            cartViewModel.removeFromCart(cartItemId: item.id)
        }
    }
    
    // Helper function to navigate between tabs
    private func goToTab(_ index: Int) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            if let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = index
            }
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    let cartViewModel: CartViewModel
    @State private var flashDecrement = false
    @State private var flashIncrement = false
    @State private var isDecrementProcessing = false
    @State private var isIncrementProcessing = false
    @State private var showDeleteAlert = false
    @State private var quantityScale: CGFloat = 1.0
    @State private var itemOffset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Product Image (Very Compact)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(width: 50, height: 50)
                
                Image(systemName: CategoryIconMap.iconName(for: item.product.category))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color(CategoryIconMap.colorName(for: item.product.category)))
            }
            
            // Product Details (Left Side Only - No Price)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.product.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(2)
                    .foregroundColor(.black)
                
                Text(item.product.weight)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 8)
            
            // Right Column: Quantity + Price + Delete (Grouped)
            VStack(alignment: .trailing, spacing: 6) {
                // Quantity Controls (Compact)
                HStack(spacing: 0) {
                    // Decrement
                    Button(action: {
                        guard !isDecrementProcessing, item.quantity > 1 else { return }
                        isDecrementProcessing = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            flashDecrement = true
                            quantityScale = 0.9
                        }
                        
                        cartViewModel.decrementQuantity(cartItemId: item.id)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                flashDecrement = false
                                quantityScale = 1.0
                            }
                            isDecrementProcessing = false
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(item.quantity <= 1 ? .gray : .green)
                            .frame(width: 26, height: 26)
                            .background(Color(.systemGray6))
                            .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                    }
                    .disabled(item.quantity <= 1 || isDecrementProcessing)
                    
                    // Quantity Display
                    Text("\(item.quantity)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 28, height: 26)
                        .background(Color.white)
                        .scaleEffect(quantityScale)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: item.quantity)
                    
                    // Increment
                    Button(action: {
                        guard !isIncrementProcessing, item.quantity < item.product.stockQuantity else { return }
                        isIncrementProcessing = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            flashIncrement = true
                            quantityScale = 0.9
                        }
                        
                        cartViewModel.incrementQuantity(cartItemId: item.id)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                flashIncrement = false
                                quantityScale = 1.0
                            }
                            isIncrementProcessing = false
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 26, height: 26)
                            .background(Color(.systemGray6))
                            .cornerRadius(5, corners: [.topRight, .bottomRight])
                    }
                    .disabled(item.quantity >= item.product.stockQuantity || isIncrementProcessing)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                )
                
                // Price Display (Right side)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("₹\(Int(item.product.price))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    if let mrp = item.product.mrp, mrp > item.product.price {
                        Text("₹\(Int(mrp))")
                            .font(.system(size: 11))
                            .strikethrough()
                            .foregroundColor(.gray)
                        
                        let percentage = ((mrp - item.product.price) / mrp) * 100
                        Text("\(Int(percentage))% OFF")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(3)
                    }
                }
                
                // Delete button (bottom-right)
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        .offset(x: itemOffset)
        .padding(.horizontal, 0)
        .padding(.vertical, 4)
        .alert("Remove Item", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                withAnimation {
                    itemOffset = -UIScreen.main.bounds.width
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    cartViewModel.removeFromCart(cartItemId: item.id)
                }
            }
        } message: {
            Text("Are you sure you want to remove '\(item.product.name)' from your cart?")
        }
    }
}

// MARK: - Detailed Bill View
struct DetailedBillView: View {
    let cartViewModel: CartViewModel
    let selectedTipAmount: Int?
    @Environment(\.dismiss) private var dismiss
    
    private var totalSavings: Double {
        var total: Double = 0.0
        for item in cartViewModel.cartItems {
            let savings = item.product.mrp != nil ? (item.product.mrp! - item.product.price) * Double(item.quantity) : 0.0
            total += savings
        }
        return total
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    itemsListSection
                    billBreakdownSection
                    savingsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Detailed Bill")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Order Summary")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var itemsListSection: some View {
        VStack(spacing: 12) {
            ForEach(cartViewModel.cartItems, id: \.id) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.product.name)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("\(item.quantity) × ₹\(Int(item.product.price))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("₹\(Int(item.product.price * Double(item.quantity)))")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var billBreakdownSection: some View {
        VStack(spacing: 16) {
            Text("Bill Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                billRow(title: "Subtotal", value: cartViewModel.subtotal)
                billRow(title: "Delivery Fee", value: cartViewModel.deliveryFee)
                
                if cartViewModel.isPromoApplied {
                    HStack {
                        Text("Promo Discount")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("-₹\(cartViewModel.discount, specifier: "%.2f")")
                            .font(.body)
                            .foregroundColor(Color("primaryRed"))
                    }
                }
                
                if let tipAmount = selectedTipAmount {
                    HStack {
                        Text("Tip")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("₹\(tipAmount)")
                            .font(.body)
                    }
                }
                
                billRow(title: "GST (5%)", value: cartViewModel.gst)
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    let totalWithTip = cartViewModel.total + Double(selectedTipAmount ?? 0)
                    Text("₹\(totalWithTip, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var savingsSection: some View {
        Group {
            if cartViewModel.cartItems.contains(where: { $0.product.discountPercentage != nil }) {
                VStack(spacing: 8) {
                    Text("You Saved")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(Int(totalSavings))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("primaryRed"))
                }
                .padding(16)
                .background(Color("primaryRed").opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private func billRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Text("₹\(value, specifier: "%.2f")")
                .font(.body)
        }
    }
}

// MARK: - Custom Tip Sheet
struct CustomTipSheet: View {
    @Binding var selectedTipAmount: Int?
    @Binding var inputText: String
    @Binding var isPresented: Bool
    
    @State private var errorText: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter a custom tip")
                    .font(.headline)
                    .padding(.top)
                
                HStack(spacing: 8) {
                    Text("₹")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    TextField("Amount", text: $inputText)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                if let errorText = errorText {
                    Text(errorText)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Custom Tip")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Apply") {
                    applyTip()
                }
                .disabled(!isValid)
            )
        }
    }
    
    private var isValid: Bool {
        guard let amount = Int(inputText.filter({ $0.isNumber })) else { return false }
        return amount > 0 && amount <= 1000
    }
    
    private func applyTip() {
        let digits = inputText.filter { $0.isNumber }
        if let amount = Int(digits), amount > 0, amount <= 1000 {
            selectedTipAmount = amount
            isPresented = false
        } else {
            errorText = "Enter a valid amount (₹1–₹1000)"
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
        .environmentObject(UserViewModel())
} 
// MARK: - Empty Cart Product Card
struct EmptyCartProductCard: View {
    let product: Product
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var isAdding = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .frame(height: 120)
                
                Image(systemName: CategoryIconMap.iconName(for: product.category))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(CategoryIconMap.colorName(for: product.category)))
            }
            
            // Product Name
            Text(product.name)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(2)
                .foregroundColor(.black)
                .frame(height: 34, alignment: .top)
            
            // Price
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₹\\(Int(product.price))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                if let mrp = product.mrp, mrp > product.price {
                    Text("₹\\(Int(mrp))")
                        .font(.system(size: 11))
                        .strikethrough()
                        .foregroundColor(.gray)
                }
            }
            
            // Add Button
            Button(action: {
                withAnimation {
                    isAdding = true
                }
                cartViewModel.addToCart(product: product, quantity: 1)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isAdding = false
                    }
                }
            }) {
                HStack {
                    Spacer()
                    if isAdding {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("ADD")
                            .font(.system(size: 12, weight: .bold))
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .frame(height: 32)
                .background(Color("primaryGreen"))
                .cornerRadius(6)
            }
            .disabled(isAdding)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}
