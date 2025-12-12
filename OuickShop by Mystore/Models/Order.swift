import Foundation

enum OrderStatus: String, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case outForDelivery = "Out for Delivery"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

enum PaymentMethod: String, Codable {
    case cashOnDelivery = "Cash On Delivery"
    case card = "Credit/Debit Card"
    case upi = "UPI"
    case creditCard = "Credit Card"
}

struct Order: Identifiable {
    let id: String
    let userId: String
    let items: [CartItem]
    let totalAmount: Double
    let address: Address
    let orderDate: Date
    let estimatedDeliveryTime: Date
    let status: OrderStatus
    let paymentMethod: PaymentMethod
    let paymentComplete: Bool
    
    var formattedOrderDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: orderDate)
    }
    
    var formattedDeliveryTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: estimatedDeliveryTime)
    }
}

// Extensions for sample data
extension Order {
    static var sampleOrders: [Order] {
        let now = Date()
        let hour: TimeInterval = 60 * 60
        
        return [
            Order(
                id: "o1",
                userId: "user1",
                items: CartItem.sampleCartItems,
                totalAmount: CartItem.sampleCartItems.reduce(0) { $0 + $1.totalPrice },
                address: Address.sampleAddresses[0],
                orderDate: now.addingTimeInterval(-2 * hour),
                estimatedDeliveryTime: now.addingTimeInterval(1 * hour),
                status: .outForDelivery,
                paymentMethod: .upi,
                paymentComplete: true
            ),
            Order(
                id: "o2",
                userId: "user1",
                items: [CartItem(id: "ci4", product: Product.sampleProducts[4], quantity: 2)],
                totalAmount: 41.98,
                address: Address.sampleAddresses[0],
                orderDate: now.addingTimeInterval(-24 * hour),
                estimatedDeliveryTime: now.addingTimeInterval(-23 * hour),
                status: .delivered,
                paymentMethod: .cashOnDelivery,
                paymentComplete: true
            )
        ]
    }
} 