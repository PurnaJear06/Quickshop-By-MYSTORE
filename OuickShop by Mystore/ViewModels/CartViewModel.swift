import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class CartViewModel: ObservableObject {
    // Firestore database reference
    private let db = Firestore.firestore()
    // Published properties for UI updates
    @Published var cartItems: [CartItem] = []
    @Published var subtotal: Double = 0
    @Published var deliveryFee: Double = 25.0 // Fixed delivery fee
    @Published var discount: Double = 0
    @Published var promoCode: String = ""
    @Published var isPromoApplied: Bool = false
    
    // Calculate GST amount from products
    var gst: Double {
        return cartItems.reduce(0.0) { total, item in
            let itemPrice = item.product.price * Double(item.quantity)
            let itemGST = (itemPrice * item.product.gst) / 100.0
            return total + itemGST
        }
    }
    
    // Total amount to pay (now includes GST from products)
    var total: Double {
        return subtotal + deliveryFee + gst - discount
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
            
            if newQuantity > 0 {
                newCartItems[index] = CartItem(
                    id: currentItem.id,
                    product: currentItem.product,
                    quantity: newQuantity
                )
                print("✅ Updated existing item quantity to: \(newQuantity)")
            } else {
                newCartItems.remove(at: index)
                print("🗑️ Removed item because quantity became 0")
            }
            
            DispatchQueue.main.async {
                self.cartItems = newCartItems
            }
        } else {
            // Add new item
            let validQuantity = min(quantity, product.stockQuantity)
            
            if validQuantity > 0 {
                let cartItem = CartItem(
                    id: UUID().uuidString, 
                    product: product, 
                    quantity: validQuantity
                )
                
                DispatchQueue.main.async {
                    self.cartItems.append(cartItem)
                    print("✅ Added new item to cart: \(product.name)")
                }
            } else {
                print("❌ Cannot add item: Stock is 0 or requested quantity is 0")
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
            
            DispatchQueue.main.async {
                if newQuantity > 0 {
                    self.cartItems[index] = CartItem(
                        id: currentItem.id,
                        product: currentItem.product,
                        quantity: newQuantity
                    )
                } else {
                    self.cartItems.remove(at: index)
                }
            }
        } else {
            // Create a mock product for the cart item
            let mockProduct = Product(
                id: UUID().uuidString,
                name: name,
                description: "Added from Quick Shop",
                price: priceValue,
                mrp: nil,
                imageURL: "",
                category: "Summer",
                isAvailable: true,
                isFeatured: false,
                weight: "1 unit",
                stockQuantity: 100,  // Increased from 10 to 100 to allow higher quantities
                gst: 5.0  // Default 5% GST
            )
            
            // Add new item
            let validQuantity = min(quantity, mockProduct.stockQuantity)
            if validQuantity > 0 {
                let cartItem = CartItem(id: UUID().uuidString, product: mockProduct, quantity: validQuantity)
                DispatchQueue.main.async {
                    self.cartItems.append(cartItem)
                }
            }
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
        
        // Force UI update
        objectWillChange.send()
        
        // Update the entire array to ensure SwiftUI detects the change
        DispatchQueue.main.async {
            self.cartItems = newCartItems
            print("✅ Successfully incremented quantity to: \(self.cartItems[index].quantity)")
            print("📊 Cart now has \(self.cartItems.count) items, subtotal: ₹\(self.subtotal)")
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
        
        // Force UI update
        objectWillChange.send()
        
        // Update the entire array to ensure SwiftUI detects the change
        DispatchQueue.main.async {
            self.cartItems = newCartItems
            if newQuantity > 0 {
                print("✅ Successfully decremented quantity to: \(self.cartItems[index].quantity)")
            } else {
                print("✅ Successfully removed item from cart")
            }
            print("📊 Cart now has \(self.cartItems.count) items, subtotal: ₹\(self.subtotal)")
        }
    }
    
    // Clear cart
    func clearCart() {
        // Automatic publisher update
        cartItems = []
    }
    
    // Apply promo code
    func applyPromoCode() {
        let code = promoCode.lowercased()
        
        if code == "welcome10" {
            // Apply 10% discount
            discount = subtotal * 0.1
            isPromoApplied = true
        } else if code == "flat50" {
            // Apply flat 50 discount
            discount = 50
            isPromoApplied = true
        } else if code == "welcome50" {
            // Apply 50% discount with ₹200 maximum cap (like Zomato/Swiggy)
            let calculatedDiscount = subtotal * 0.5
            discount = min(calculatedDiscount, 200)
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
        // Get current user ID
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "User not logged in")
            return
        }
        
        // Check cart not empty
        guard !cartItems.isEmpty else {
            completion(false, "Your cart is empty")
            return
        }
        
        // Generate unique order ID
        let orderId = "OD\(Int.random(in: 100000...999999))"
        
        // Build order data for Firestore
        let orderData: [String: Any] = [
            "orderId": orderId,
            "userId": userId,
            "items": cartItems.map { item in
                [
                    "productId": item.product.id,
                    "productName": item.product.name,
                    "quantity": item.quantity,
                    "price": item.product.price,
                    "total": item.totalPrice
                ]
            },
            "subtotal": subtotal,
            "deliveryFee": deliveryFee,
            "gst": gst,
            "discount": discount,
            "total": total,
            "address": [
                "title": address.title,
                "fullAddress": address.fullAddress,
                "landmark": address.landmark ?? ""
            ],
            "paymentMethod": paymentMethod.rawValue,
            "paymentStatus": "pending",
            "orderStatus": "pending",
            "orderDate": Timestamp(),
            "estimatedDelivery": Timestamp(date: Date().addingTimeInterval(30*60)), // 30 min ETA
            "createdAt": Timestamp(),
            "updatedAt": Timestamp()
        ]
        
        // Save order to Firestore
        db.collection("orders").document(orderId).setData(orderData) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Order save failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else {
                    print("✅ Order \(orderId) saved successfully to Firestore")
                    self.clearCart()
                    completion(true, nil)
                }
            }
        }
    }
} 