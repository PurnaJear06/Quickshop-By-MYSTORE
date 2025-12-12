import SwiftUI

struct OrderCardView: View {
    let order: Order
    let onReorder: () -> Void
    
    @State private var showReorderFeedback = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row: Order ID + Date + Status
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("#\(order.id.uppercased())")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(order.formattedOrderDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                statusBadge
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Product Thumbnails
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(order.items.prefix(5)) { item in
                        productThumbnail(for: item)
                    }
                    
                    if order.items.count > 5 {
                        Text("+\(order.items.count - 5)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 45, height: 45)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Bottom Row: Total + Actions
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text("₹\(Int(order.totalAmount))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Reorder Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showReorderFeedback = true
                    }
                    onReorder()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showReorderFeedback = false
                    }
                }) {
                    HStack(spacing: 6) {
                        if showReorderFeedback {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .semibold))
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Text(showReorderFeedback ? "Added!" : "Reorder")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(showReorderFeedback ? Color.green : Color("primaryGreen"))
                    .cornerRadius(8)
                }
                
                // View Details Link
                Button(action: {
                    // Navigate to order details
                }) {
                    Text("Details")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("primaryGreen"))
                }
                .padding(.leading, 12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            Text(order.status.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.12))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch order.status {
        case .delivered:
            return .green
        case .cancelled:
            return .red
        case .outForDelivery:
            return .blue
        case .confirmed:
            return Color("primaryGreen")
        case .pending:
            return Color("primaryYellow")
        }
    }
    
    // MARK: - Product Thumbnail
    private func productThumbnail(for item: CartItem) -> some View {
        ZStack {
            // Product Image
            if let url = URL(string: item.product.imageURL), item.product.imageURL.hasPrefix("http") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 45, height: 45)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 45)
                            .clipped()
                    case .failure:
                        fallbackImage
                    @unknown default:
                        fallbackImage
                    }
                }
            } else {
                // Local asset image
                Image(item.product.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipped()
            }
            
            // Quantity badge
            if item.quantity > 1 {
                Text("×\(item.quantity)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .offset(x: 12, y: 12)
            }
        }
        .frame(width: 45, height: 45)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var fallbackImage: some View {
        Image(systemName: "photo")
            .foregroundColor(.secondary)
            .frame(width: 45, height: 45)
            .background(Color(.systemGray6))
    }
}

#Preview {
    VStack {
        OrderCardView(
            order: Order.sampleOrders[0],
            onReorder: {}
        )
        .padding()
    }
    .background(Color("primaryYellow").opacity(0.12))
}
