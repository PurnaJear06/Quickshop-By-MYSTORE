import SwiftUI

struct ProductCard: View {
    let product: Product
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var showingProductDetail = false
    @State private var addingToCart = false
    @State private var showAddedFeedback = false
    
    // Check if product is in cart and get quantity
    private var cartItem: CartItem? {
        cartViewModel.cartItems.first { $0.product.id == product.id }
    }
    
    private var isInCart: Bool {
        cartItem != nil
    }
    
    private var cartQuantity: Int {
        cartItem?.quantity ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Product Image
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Image(systemName: CategoryIconMap.iconName(for: product.category))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(12)
                        .frame(width: 90, height: 90)
                        .foregroundColor(.gray)
                }
                .frame(width: 120, height: 120)
                .background(Color.white)
                .cornerRadius(8)
                
                // Discount badge if available with improved styling
                if let discountPercentage = product.discountPercentage {
                    Text("\(discountPercentage)% OFF")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("primaryRed"), Color("primaryRed").opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(4)
                        .shadow(color: Color("primaryRed").opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding(6)
                }
            }
            
            // Product information
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                
                Text(product.weight)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                
                // Delivery time
                HStack(spacing: 2) {
                    Image(systemName: "timer")
                        .font(.system(size: 9))
                        .foregroundColor(.green)
                    
                    Text("13 MINS")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .padding(.top, 1)
                
                // Price section with MRP and discount
                VStack(alignment: .leading, spacing: 2) {
                    // Show MRP with strikethrough if available
                    if let mrp = product.mrp, mrp > product.price {
                        Text("₹\(Int(mrp))")
                            .font(.caption)
                            .strikethrough()
                            .foregroundColor(.gray)
                    }
                    
                    // Show selling price
                    Text("₹\(Int(product.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("primaryGreen"))
                    
                    // Show discount badge
                    if let discount = product.discountPercentage {
                        Text("\(discount)% OFF")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 4)
            
            // Enhanced Add Button with Quantity Controls
            if isInCart && cartQuantity > 0 {
                // Quantity Controls
                HStack(spacing: 0) {
                    // Decrease Button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.15)) {
                            addingToCart = true
                        }
                        
                        if cartQuantity > 1 {
                            cartViewModel.updateQuantity(cartItemId: cartItem!.id, quantity: cartQuantity - 1)
                        } else {
                            cartViewModel.removeFromCart(cartItemId: cartItem!.id)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                addingToCart = false
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color("primaryRed"))
                            .cornerRadius(3, corners: [.topLeft, .bottomLeft])
                    }
                    
                    // Quantity Display
                    Text("\(cartQuantity)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 20)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(width: 1)
                                .foregroundColor(Color.gray.opacity(0.3)),
                            alignment: .leading
                        )
                        .overlay(
                            Rectangle()
                                .frame(width: 1)
                                .foregroundColor(Color.gray.opacity(0.3)),
                            alignment: .trailing
                        )
                    
                    // Increase Button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.15)) {
                            addingToCart = true
                        }
                        
                        cartViewModel.updateQuantity(cartItemId: cartItem!.id, quantity: cartQuantity + 1)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                addingToCart = false
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color("primaryRed"))
                            .cornerRadius(3, corners: [.topRight, .bottomRight])
                    }
                }
                .scaleEffect(addingToCart ? 0.95 : 1.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
            } else {
                // Add Button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 0.15)) {
                        addingToCart = true
                        showAddedFeedback = true
                    }
                    
                    cartViewModel.addToCart(product: product)
                    
                    // Show success feedback
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            addingToCart = false
                        }
                        
                        // Hide success feedback after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showAddedFeedback = false
                            }
                        }
                    }
                }) {
                    HStack(spacing: 3) {
                        if showAddedFeedback {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(showAddedFeedback ? "ADDED" : "ADD")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(showAddedFeedback ? Color("primaryGreen") : Color("primaryRed"))
                    )
                    .scaleEffect(addingToCart ? 0.95 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
            }
        }
        .frame(width: 120, height: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .onTapGesture {
            showingProductDetail = true
        }
        .sheet(isPresented: $showingProductDetail) {
            ProductDetailView(product: product)
        }
    }
}

#Preview {
    ProductCard(product: Product.sampleProducts[0])
        .environmentObject(CartViewModel())
        .padding()
        .background(Color.gray.opacity(0.1))
} 