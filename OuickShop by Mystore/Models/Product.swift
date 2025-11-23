import Foundation

struct Product: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let discountPrice: Double?
    let imageURL: String
    let category: String
    let isAvailable: Bool
    let isFeatured: Bool
    let weight: String // e.g., "500g", "1kg"
    let stockQuantity: Int
    
    var discountPercentage: Int? {
        guard let discountPrice = discountPrice else { return nil }
        let discount = price - discountPrice
        return Int((discount / price) * 100)
    }
    
    // Equatable conformance - needed for SwiftUI to properly detect changes
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id && 
               lhs.name == rhs.name && 
               lhs.price == rhs.price && 
               lhs.discountPrice == rhs.discountPrice &&
               lhs.stockQuantity == rhs.stockQuantity
    }
}
// Extensions for sample data
extension Product {
    static var sampleProducts: [Product] {
        [
            Product(id: "p1", name: "Fresh Bananas", description: "Organic ripe bananas", price: 49.99, discountPrice: 39.99, imageURL: "banana", category: "Fruits", isAvailable: true, isFeatured: true, weight: "1kg", stockQuantity: 100),
            Product(id: "p2", name: "Tomatoes", description: "Farm fresh tomatoes", price: 35.00, discountPrice: nil, imageURL: "tomato", category: "Vegetables", isAvailable: true, isFeatured: false, weight: "500g", stockQuantity: 100),
            Product(id: "p3", name: "Whole Milk", description: "Fresh cow milk", price: 55.00, discountPrice: 45.00, imageURL: "milk", category: "Dairy", isAvailable: true, isFeatured: true, weight: "1L", stockQuantity: 100),
            Product(id: "p4", name: "Brown Bread", description: "Freshly baked bread", price: 30.00, discountPrice: nil, imageURL: "bread", category: "Bakery", isAvailable: true, isFeatured: false, weight: "400g", stockQuantity: 100),
            Product(id: "p5", name: "Spinach", description: "Fresh green spinach", price: 25.99, discountPrice: 20.99, imageURL: "spinach", category: "Vegetables", isAvailable: true, isFeatured: true, weight: "250g", stockQuantity: 100),
            Product(id: "p6", name: "Chicken Breast", description: "Boneless chicken breast", price: 199.99, discountPrice: 179.99, imageURL: "chicken", category: "Meat", isAvailable: true, isFeatured: true, weight: "500g", stockQuantity: 100),
            Product(id: "p7", name: "Eggs", description: "Farm fresh eggs", price: 89.99, discountPrice: nil, imageURL: "eggs", category: "Dairy", isAvailable: true, isFeatured: false, weight: "12pcs", stockQuantity: 100),
            Product(id: "p8", name: "Avocado", description: "Ripe avocados", price: 79.99, discountPrice: 69.99, imageURL: "avocado", category: "Fruits", isAvailable: true, isFeatured: true, weight: "500g", stockQuantity: 100)
        ]
    }
} 
