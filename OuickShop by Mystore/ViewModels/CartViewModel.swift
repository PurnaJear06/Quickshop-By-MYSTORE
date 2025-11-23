import Foundation
import Combine

class CartViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var cartItems: [CartItem] = []
    @Published var subtotal: Double = 0
    @Published var deliveryFee: Double = 25.0 // Fixed delivery fee
    @Published var discount: Double = 0
    @Published var promoCode: String = ""
    @Published var isPromoApplied: Bool = false
    
    // GST rate (5%)
    let gstRate: Double = 0.05
    
    // Calculate GST amount
    var gst: Double {
        return subtotal * gstRate
    }
    
    // Total amount to pay (now includes GST)
    var total: Double {
        subtotal + deliveryFee + gst - discount
    }
    
    // Cancellables for Combine
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load mock data for cart (in a real app, this would fetch from local storage or Firebase)
        loadCart()
        
        // Setup observers
        setupObservers()
    }
    
    private func loadCart() {
        // Start with empty cart for testing - FIXED: Removed sample items that were causing issues
        self.cartItems = []
        self.calculateSubtotal()
    }
    
    private func setupObservers() {
        // Observe cart items and recalculate subtotal when they change
        $cartItems
            .sink { [weak self] _ in
                self?.calculateSubtotal()
            }
            .store(in: &cancellables)
    }
    
    private func calculateSubtotal() {
        subtotal = cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    // MARK: - Fixed Cart Management Methods
    
    // Add item to cart - FIXED: Proper SwiftUI state management
    func addToCart(product: Product, quantity: Int = 1) {
        print("🛒 ADD TO CART called for product: \(product.name), quantity: \(quantity)")
        
        // Check if product already exists in cart
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            // Update existing item
            let currentItem = cartItems[index]
            let newQuantity = min(currentItem.quantity + quantity, currentItem.product.stockQuantity)
            
            var newCartItems = cartItems
            newCartItems[index] = CartItem(
                id: currentItem.id,
                product: currentItem.product,
                quantity: newQuantity
            )
            
            DispatchQueue.main.async {
                self.cartItems = newCartItems
                print("✅ Updated existing item quantity to: \(newQuantity)")
            }
        } else {
            // Add new item
            let cartItem = CartItem(
                id: UUID().uuidString, 
                product: product, 
                quantity: min(quantity, product.stockQuantity)
            )
            
            DispatchQueue.main.async {
                self.cartItems.append(cartItem)
                print("✅ Added new item to cart: \(product.name)")
            }
        }
    }
    
    // Add item to cart using name and price - Fixed for consistency
    func addToCart(name: String, price: String, quantity: Int = 1) {
        // Convert price string to double
        let priceValue = Double(price.replacingOccurrences(of: "₹", with: "")) ?? 0.0
        
        // Check if item with the same name already exists
        if let index = cartItems.firstIndex(where: { $0.product.name == name }) {
            // Update existing item
            let currentItem = cartItems[index]
            let newQuantity = min(currentItem.quantity + quantity, currentItem.product.stockQuantity)
            
            cartItems[index] = CartItem(
                id: currentItem.id,
                product: currentItem.product,
                quantity: newQuantity
            )
        } else {
            // Create a mock product for the cart item
            let mockProduct = Product(
                id: UUID().uuidString,
                name: name,
                description: "Added from Quick Shop",
                price: priceValue,
                discountPrice: nil,
                imageURL: "",
                category: "Summer",
                isAvailable: true,
                isFeatured: false,
                weight: "1 unit",
                stockQuantity: 100  // Increased from 10 to 100 to allow higher quantities
            )
            
            // Add new item
            let cartItem = CartItem(id: UUID().uuidString, product: mockProduct, quantity: quantity)
            cartItems.append(cartItem)
        }
    }
    
    // Remove item from cart using the cart item's own identifier - FIXED: Proper SwiftUI state management
    func removeFromCart(cartItemId: String) {
        print("🗑️ REMOVE FROM CART called for cartItemId: \(cartItemId)")
        
        DispatchQueue.main.async {
            self.cartItems.removeAll { $0.id == cartItemId }
            print("✅ Successfully removed item from cart")
        }
    }
    
    // Update item quantity for a specific cart item id - FIXED: Proper SwiftUI state management
    func updateQuantity(cartItemId: String, quantity: Int) {
        print("📝 UPDATE QUANTITY called for cartItemId: \(cartItemId), new quantity: \(quantity)")
        
        guard quantity > 0 else {
            removeFromCart(cartItemId: cartItemId)
            return
        }
        
        guard let index = cartItems.firstIndex(where: { $0.id == cartItemId }) else {
            print("❌ Cart item not found for update")
            return
        }
        
        let currentItem = cartItems[index]
        let newQuantity = min(quantity, currentItem.product.stockQuantity)
        
        var newCartItems = cartItems
        newCartItems[index] = CartItem(
            id: currentItem.id,
            product: currentItem.product,
            quantity: newQuantity
        )
        
        DispatchQueue.main.async {
            self.cartItems = newCartItems
            print("✅ Successfully updated quantity to: \(newQuantity)")
        }
    }
    
    // Increment quantity by 1 for the tapped cart item - COMPLETELY REWRITTEN: Fixed SwiftUI state issues
    func incrementQuantity(cartItemId: String) {
        print("🔼 INCREMENT called for cartItemId: \(cartItemId)")
        print("🔼 Current cart items count: \(cartItems.count)")
        
        guard let index = cartItems.firstIndex(where: { $0.id == cartItemId }) else {
            print("❌ Cart item not found for id: \(cartItemId)")
            return
        }
        
        let currentItem = cartItems[index]
        print("🔼 Found item: \(currentItem.product.name), current quantity: \(currentItem.quantity), stock: \(currentItem.product.stockQuantity)")
        
        // Check if already at stock limit
        guard currentItem.quantity < currentItem.product.stockQuantity else {
            print("❌ Cannot increment - already at stock limit (\(currentItem.quantity)/\(currentItem.product.stockQuantity))")
            return
        }
        
        let newQuantity = currentItem.quantity + 1
        print("🔼 New quantity will be: \(newQuantity)")
        
        // CRITICAL FIX: Create a completely new array to trigger SwiftUI updates
        var newCartItems = cartItems
        let updatedItem = CartItem(
            id: currentItem.id,
            product: currentItem.product,
            quantity: newQuantity
        )
        newCartItems[index] = updatedItem
        
        // Update the entire array to ensure SwiftUI detects the change
        DispatchQueue.main.async {
            self.cartItems = newCartItems
            print("✅ Successfully incremented quantity to: \(self.cartItems[index].quantity)")
        }
    }
    
    // Decrement quantity by 1 for the tapped cart item - COMPLETELY REWRITTEN: Fixed SwiftUI state issues
    func decrementQuantity(cartItemId: String) {
        print("🔽 DECREMENT called for cartItemId: \(cartItemId)")
        print("🔽 Current cart items count: \(cartItems.count)")
        
        guard let index = cartItems.firstIndex(where: { $0.id == cartItemId }) else {
            print("❌ Cart item not found for id: \(cartItemId)")
            return
        }
        
        let currentItem = cartItems[index]
        print("🔽 Found item: \(currentItem.product.name), current quantity: \(currentItem.quantity)")
        
        // Check if already at minimum quantity
        guard currentItem.quantity > 1 else {
            print("❌ Cannot decrement - already at minimum quantity (1)")
            return
        }
        
        let newQuantity = currentItem.quantity - 1
        print("🔽 New quantity will be: \(newQuantity)")
        
        // CRITICAL FIX: Create a completely new array to trigger SwiftUI updates
        var newCartItems = cartItems
        
        if newQuantity <= 0 {
            print("🗑️ Removing item from cart")
            newCartItems.remove(at: index)
        } else {
            let updatedItem = CartItem(
                id: currentItem.id,
                product: currentItem.product,
                quantity: newQuantity
            )
            newCartItems[index] = updatedItem
        }
        
        // Update the entire array to ensure SwiftUI detects the change
        DispatchQueue.main.async {
            self.cartItems = newCartItems
            if newQuantity > 0 {
                print("✅ Successfully decremented quantity to: \(self.cartItems[index].quantity)")
            } else {
                print("✅ Successfully removed item from cart")
            }
        }
    }
    
    // Clear cart
    func clearCart() {
        // Automatic publisher update
        cartItems = []
    }
    
    // Apply promo code
    func applyPromoCode() {
        // Mock promo code validation
        if promoCode.lowercased() == "welcome10" {
            // Apply 10% discount
            discount = subtotal * 0.1
            isPromoApplied = true
        } else if promoCode.lowercased() == "flat50" {
            // Apply flat 50 discount
            discount = 50
            isPromoApplied = true
        } else {
            // Invalid promo code
            discount = 0
            isPromoApplied = false
        }
    }
    
    // Remove promo code
    func removePromoCode() {
        promoCode = ""
        discount = 0
        isPromoApplied = false
    }
    
    // Checkout
    func checkout(address: Address, paymentMethod: PaymentMethod, completion: @escaping (Bool, String?) -> Void) {
        // In a real app, this would create an order in Firebase
        // For now, just simulate a successful checkout
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Simulate success
            if !self.cartItems.isEmpty {
                self.clearCart()
                completion(true, nil)
            } else {
                completion(false, "Your cart is empty")
            }
        }
    }
} 