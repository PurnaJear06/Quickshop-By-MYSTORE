import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = true
    @State private var orders: [Order] = []
    
    var body: some View {
        ZStack {
            // Light yellow background
            Color("primaryYellow").opacity(0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if isLoading {
                    loadingView
                } else if orders.isEmpty {
                    emptyStateView
                } else {
                    orderListView
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadOrders()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            Text("My Orders")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading orders...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bag")
                .font(.system(size: 60))
                .foregroundColor(Color("primaryYellow"))
            
            Text("No orders yet")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text("Your order history will appear here\nonce you place your first order.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { dismiss() }) {
                Text("Start Shopping")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("primaryGreen"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Order List
    private var orderListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(orders) { order in
                    OrderCardView(order: order, onReorder: { reorderItems(from: order) })
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .refreshable {
            await refreshOrders()
        }
    }
    
    // MARK: - Functions
    private func loadOrders() {
        isLoading = true
        
        // Simulate loading from Firebase
        // In production, this would fetch from Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Use sample orders for now
            // Replace with actual Firebase fetch
            self.orders = userViewModel.orders
            self.isLoading = false
        }
    }
    
    private func refreshOrders() async {
        // Refresh orders from Firebase
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            self.orders = userViewModel.orders
        }
    }
    
    private func reorderItems(from order: Order) {
        // Add all items from the order to cart
        for item in order.items {
            cartViewModel.addToCart(product: item.product, quantity: item.quantity)
        }
        
        // Show feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    OrderHistoryView()
        .environmentObject(UserViewModel())
        .environmentObject(CartViewModel())
}
