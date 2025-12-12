import SwiftUI

struct CheckoutView: View {
    // Environment objects
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    // Bindings
    @Binding var selectedAddress: Address?
    @Binding var selectedPaymentMethod: PaymentMethod
    
    // State
    @State private var isProcessingOrder = false
    @State private var showingOrderSuccess = false
    @State private var showingAddressSheet = false
    @State private var orderID: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Delivery Address Section
                        addressSection
                        
                        // Payment Method Section
                        paymentMethodSection
                        
                        // Order Summary Section
                        orderSummarySection
                    }
                    .padding()
                }
                .overlay(
                    Group {
                        if isProcessingOrder {
                            ZStack {
                                Color.black.opacity(0.4).ignoresSafeArea()
                                
                                VStack(spacing: 20) {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                    
                                    Text("Processing your order...")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding(30)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(15)
                            }
                        }
                    }
                )
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .fullScreenCover(isPresented: $showingOrderSuccess) {
                OrderSuccessView(orderID: orderID)
            }
            .sheet(isPresented: $showingAddressSheet) {
                AddressSelectionView(selectedAddress: $selectedAddress)
            }
        }
    }
    
    // Address Section
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Delivery Address")
                .font(.headline)
            
            if let address = selectedAddress {
                // Selected Address
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(address.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Button("Change") {
                            showingAddressSheet = true
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                    }
                    
                    Text(address.fullAddress)
                        .font(.subheadline)
                    
                    if let landmark = address.landmark {
                        Text("Landmark: \(landmark)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            } else {
                // No Address Selected
                Button(action: {
                    showingAddressSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Delivery Address")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundColor(.green)
                }
            }
        }
    }
    
    // Payment Method Section
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Method")
                .font(.headline)
            
            VStack(spacing: 0) {
                // Cash on Delivery
                paymentMethodButton(
                    method: .cashOnDelivery,
                    icon: "banknote",
                    isSelected: selectedPaymentMethod == .cashOnDelivery
                )
                
                Divider()
                
                // Card Payment
                paymentMethodButton(
                    method: .card,
                    icon: "creditcard",
                    isSelected: selectedPaymentMethod == .card
                )
                
                Divider()
                
                // UPI Payment
                paymentMethodButton(
                    method: .upi,
                    icon: "wallet.pass",
                    isSelected: selectedPaymentMethod == .upi
                )
            }
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    private func paymentMethodButton(method: PaymentMethod, icon: String, isSelected: Bool) -> some View {
        Button(action: {
            selectedPaymentMethod = method
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isSelected ? .green : .primary)
                
                Text(method.rawValue)
                    .font(.subheadline)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(isSelected ? Color.green.opacity(0.1) : Color.white)
        }
        .foregroundColor(.primary)
    }
    
    // Order Summary Section
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Items and Pricing
                VStack(spacing: 8) {
                    HStack {
                        Text("Items (\(cartViewModel.cartItems.count))")
                        Spacer()
                        Text("₹\(cartViewModel.subtotal, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Delivery Fee")
                        Spacer()
                        Text("₹\(cartViewModel.deliveryFee, specifier: "%.2f")")
                    }
                    
                    if cartViewModel.discount > 0 {
                        HStack {
                            Text("Discount")
                                .foregroundColor(.green)
                            Spacer()
                            Text("-₹\(cartViewModel.discount, specifier: "%.2f")")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("₹\(cartViewModel.total, specifier: "%.2f")")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                // Place Order Button
                Button(action: placeOrder) {
                    Text("Place Order")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedAddress != nil ? Color.green : Color.gray
                        )
                        .cornerRadius(10)
                }
                .disabled(selectedAddress == nil || isProcessingOrder)
            }
        }
    }
    
    // Place Order Function
    private func placeOrder() {
        guard let address = selectedAddress else { return }
        
        isProcessingOrder = true
        
        // Simulate order placement
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            orderID = "OD\(Int.random(in: 100000...999999))"
            
            cartViewModel.checkout(address: address, paymentMethod: selectedPaymentMethod) { success, error in
                isProcessingOrder = false
                
                if success {
                    showingOrderSuccess = true
                } else {
                    // Handle error (show alert)
                    print("Error placing order: \(error ?? "Unknown error")")
                }
            }
        }
    }
}

struct OrderSuccessView: View {
    let orderID: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Success Animation
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
                
                VStack(spacing: 10) {
                    Text("Order Placed Successfully!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your order #\(orderID) has been placed successfully.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Estimated delivery: 30-40 mins")
                        .font(.headline)
                        .padding(.top)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue Shopping")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 250)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
}

struct AddressSelectionView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var selectedAddress: Address?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userViewModel.currentUser?.addresses ?? []) { address in
                    AddressRow(
                        address: address,
                        isSelected: selectedAddress?.id == address.id
                    )
                    .onTapGesture {
                        selectedAddress = address
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Address")
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct AddressRow: View {
    let address: Address
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(address.title)
                        .font(.headline)
                    
                    if address.isDefault {
                        Text("Default")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
                
                Text(address.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let landmark = address.landmark {
                    Text("Landmark: \(landmark)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CheckoutView(
        selectedAddress: .constant(Address.sampleAddresses[0]),
        selectedPaymentMethod: .constant(.cashOnDelivery)
    )
    .environmentObject(CartViewModel())
    .environmentObject(UserViewModel())
} 