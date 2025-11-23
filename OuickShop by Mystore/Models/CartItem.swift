import Foundation

struct CartItem: Identifiable, Equatable {
    let id: String
    let product: Product
    var quantity: Int
    
    var totalPrice: Double {
        let pricePerUnit = product.discountPrice ?? product.price
        return pricePerUnit * Double(quantity)
    }
    
    // Equatable conformance - needed for SwiftUI to properly detect changes
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.id == rhs.id && 
               lhs.quantity == rhs.quantity && 
               lhs.product.id == rhs.product.id
    }
}

// Extensions for sample data
extension CartItem {
    static var sampleCartItems: [CartItem] {
        [
            CartItem(id: "ci1", product: Product.sampleProducts[0], quantity: 2),
            CartItem(id: "ci2", product: Product.sampleProducts[2], quantity: 1),
            CartItem(id: "ci3", product: Product.sampleProducts[5], quantity: 3)
        ]
    }
} 