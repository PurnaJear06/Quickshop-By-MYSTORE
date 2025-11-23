import SwiftUI

struct ProductDetailView: View {
    // Props
    let product: Product
    
    // Environment objects
    @EnvironmentObject var cartViewModel: CartViewModel
    
    // State
    @State private var quantity = 1
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Product Image
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: CategoryIconMap.iconName(for: product.category))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(40)
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                            .background(Color(CategoryIconMap.colorName(for: product.category)).opacity(0.1))
                        
                        // Discount badge if available
                        if let discountPercentage = product.discountPercentage {
                            Text("\(discountPercentage)% OFF")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.red)
                                .cornerRadius(8)
                                .padding()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Product Name and Category
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(product.weight)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: CategoryIconMap.iconName(for: product.category))
                                    .foregroundColor(Color(CategoryIconMap.colorName(for: product.category)))
                                
                                Text(product.category)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        
                        // Price
                        HStack(alignment: .firstTextBaseline) {
                            if let discountPrice = product.discountPrice {
                                Text("₹\(discountPrice, specifier: "%.2f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("₹\(product.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                            } else {
                                Text("₹\(product.price, specifier: "%.2f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            // In stock indicator
                            if product.isAvailable {
                                Text("In Stock: \(product.stockQuantity)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(4)
                            } else {
                                Text("Out of Stock")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        
                        Divider()
                        
                        // Description
                        Text("Description")
                            .font(.headline)
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        // Quantity Selector
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                
                                Text("\(quantity)")
                                    .font(.headline)
                                    .frame(width: 40)
                                
                                Button(action: {
                                    if quantity < product.stockQuantity {
                                        quantity += 1
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        
                        // Total Price
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("₹\((product.discountPrice ?? product.price) * Double(quantity), specifier: "%.2f")")
                                .font(.headline)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            
            // Add to Cart button at bottom
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Price")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("₹\((product.discountPrice ?? product.price) * Double(quantity), specifier: "%.2f")")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    ConsistentButton.secondary(
                        title: "Add to Cart",
                        action: {
                            cartViewModel.addToCart(product: product, quantity: quantity)
                            dismiss()
                        },
                        isEnabled: product.isAvailable
                    )
                    .frame(width: 180)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        ProductDetailView(product: Product.sampleProducts[0])
            .environmentObject(CartViewModel())
    }
} 