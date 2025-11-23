import SwiftUI

struct CartView: View {
    // Environment objects
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
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
        return cartViewModel.cartItems.reduce(0) { total, item in
            if let discountPrice = item.product.discountPrice {
                return total + ((item.product.price - discountPrice) * Double(item.quantity))
            }
            return total
        }
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            if cartViewModel.cartItems.isEmpty {
                // Empty Cart View
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("Your cart is empty")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Add items to get started")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    ConsistentButton.secondary(
                        title: "Start Shopping",
                        action: {
                            goToTab(0)
                        }
                    )
                    .frame(width: 200)
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
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            // Simple light gray header matching the screenshot
            HStack {
                Button(action: {
                    goToTab(0)
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                Text("My Cart")
                    .font(.headline)
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
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
        }
    }
    
    // MARK: - Savings Banner
    private var savingsBanner: some View {
        HStack {
            Text("Saved")
                .font(.headline)
                .foregroundColor(.black)
            
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("primaryRed"))
                    .frame(height: 28)
                
                Text("₹\(Int(totalSavings))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
            }
            .fixedSize()
            
            Text("with this order")
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color("primaryRed").opacity(0.1))
        .cornerRadius(8)
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
    
    // MARK: - Tipping Section
    private var tippingSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Say thanks with a tip")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
            }
            
            Text("A small tip, a big gesture! Tip your delivery partner to show appreciation for their hard work.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
                ForEach(tipOptions, id: \.self) { amount in
                    Button(action: {
                        selectedTipAmount = amount
                    }) {
                        VStack(spacing: 4) {
                            Text("₹\(amount)")
                                .font(.headline)
                                .foregroundColor(selectedTipAmount == amount ? .white : .primary)
                            
                            if amount == defaultTipOption {
                                Text("Most tipped")
                                    .font(.caption)
                                    .foregroundColor(selectedTipAmount == amount ? .white : .blue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTipAmount == amount ? Color("primaryBlue") : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTipAmount == amount ? Color("primaryBlue") : Color.gray.opacity(0.2), lineWidth: 1)
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
                            .font(.headline)
                            .foregroundColor(isCustom ? .white : .primary)
                        if isCustom {
                            Text("Custom")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isCustom ? Color("primaryBlue") : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isCustom ? Color("primaryBlue") : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            
            if selectedTipAmount != nil {
                Button(action: { selectedTipAmount = nil }) {
                    Text("Remove tip")
                        .font(.caption)
                        .foregroundColor(Color("primaryBlue"))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
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
    
    // MARK: - Bill Details Section
    private var billDetailsSection: some View {
        VStack(spacing: 16) {
            Text("Bill Details")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Group {
                billRow(title: "Item Total", value: cartViewModel.subtotal, originalValue: nil)
                
                billRow(title: "Delivery Fee", value: cartViewModel.deliveryFee, originalValue: nil)
                
                if selectedTipAmount != nil {
                    billRow(title: "Delivery Tip", value: Double(selectedTipAmount!), originalValue: nil)
                } else {
                    HStack {
                        Text("Delivery Tip")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            selectedTipAmount = defaultTipOption
                        }) {
                            Text("Add a tip")
                                .font(.body)
                                .foregroundColor(Color("primaryBlue"))
                        }
                    }
                }
                
                HStack {
                    Text("Delivery Partner Fee")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("₹16.00")
                        .font(.body)
                        .strikethrough()
                        .foregroundColor(.gray)
                    
                    Text("FREE")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(Color("primaryRed"))
                }
                
                billRow(title: "GST and Charges", value: cartViewModel.gst, originalValue: nil)
            }
            .padding(.vertical, 4)
            
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                Text("To Pay")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                if totalSavings > 0 {
                    Text("₹\(cartViewModel.total + totalSavings, specifier: "%.2f")")
                        .font(.body)
                        .strikethrough()
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
                
                let totalWithTip = cartViewModel.total + Double(selectedTipAmount ?? 0)
                Text("₹\(totalWithTip, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // MARK: - Helper for Bill Row
    private func billRow(title: String, value: Double, originalValue: Double?) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let original = originalValue {
                Text("₹\(original, specifier: "%.2f")")
                    .font(.body)
                    .strikethrough()
                    .foregroundColor(.gray)
                    .padding(.trailing, 8)
            }
            
            Text("₹\(value, specifier: "%.2f")")
                .font(.body)
        }
    }
    
    // MARK: - Cancellation Policy Section
    private var cancellationPolicySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTE:")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("Orders cannot be cancelled and are non-refundable once packed for delivery.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                // Show cancellation policy
            }) {
                Text("Read cancellation policy")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("primaryBlue"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // MARK: - Checkout Button Section
    private var checkoutButtonSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                    let totalWithTip = cartViewModel.total + Double(selectedTipAmount ?? 0)
                    Text("₹\(totalWithTip, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Button(action: {
                        showingDetailedBill = true
                    }) {
                        Text("View Detailed Bill")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color("primaryBlue"))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if userViewModel.isLoggedIn {
                        if let defaultAddress = userViewModel.currentUser?.addresses.first(where: { $0.isDefault }) {
                            selectedAddress = defaultAddress
                            showingCheckout = true
                        } else {
                            // No default address, navigate to address selection
                            showingCheckout = true
                        }
                    } else {
                        // Navigate to Login Tab
                        goToTab(3)
                    }
                }) {
                    Text(userViewModel.isLoggedIn ? "Proceed to Pay" : "Login to Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(Color("primaryRed"))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, max(16, UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.safeAreaInsets.bottom ?? 16))
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Product Image with shadow and better styling
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 65, height: 65)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: CategoryIconMap.iconName(for: item.product.category))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(CategoryIconMap.colorName(for: item.product.category)))
                }
                .padding(.vertical, 4)
                
                // Middle column - product details
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.product.name)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                    
                    Text(item.product.weight)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    // Price with discount
                    if let discountPrice = item.product.discountPrice {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("₹\(Int(discountPrice))")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("₹\(Int(item.product.price))")
                                .font(.system(size: 14))
                                .strikethrough()
                                .foregroundColor(.gray)
                            
                            if let percentage = item.product.discountPercentage {
                                Text("\(percentage)% OFF")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color("primaryRed"))
                            }
                        }
                    } else {
                        Text("₹\(Int(item.product.price))")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .padding(.vertical, 8)
                
                Spacer()
                
                // Right column - delete and quantity controls
                VStack(alignment: .trailing, spacing: 8) {
                    // Delete button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.8))
                            .frame(width: 28, height: 28)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Quantity controls
                    HStack(spacing: 0) {
                        // Decrement Button
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
                            Text("−")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(item.quantity <= 1 ? .gray : .black)
                                .frame(width: 32, height: 32)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(4, corners: [.topLeft, .bottomLeft])
                        }
                        .disabled(item.quantity <= 1 || isDecrementProcessing)
                        
                        // Quantity Display
                        Text("\(item.quantity)")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .scaleEffect(quantityScale)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: item.quantity)
                        
                        // Increment Button
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
                            Text("+")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color("primaryRed"))
                                .frame(width: 32, height: 32)
                                .background(Color("primaryRed").opacity(0.15))
                                .cornerRadius(4, corners: [.topRight, .bottomRight])
                        }
                        .disabled(item.quantity >= item.product.stockQuantity || isIncrementProcessing)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(8)
        .offset(x: itemOffset)
        .padding(.horizontal, 2)
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
            if let discountPrice = item.product.discountPrice {
                let savings = (item.product.price - discountPrice) * Double(item.quantity)
                total += savings
            }
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
                        
                        Text("\(item.quantity) × ₹\(Int(item.product.discountPrice ?? item.product.price))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("₹\(Int((item.product.discountPrice ?? item.product.price) * Double(item.quantity)))")
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