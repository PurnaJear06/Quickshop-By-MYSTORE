import SwiftUI
import UserNotifications
import UIKit

struct ProfileView: View {
    // Environment objects
    @EnvironmentObject var userViewModel: UserViewModel
    
    // State
    @State private var showingAddAddressSheet = false
    @State private var showingEditProfileSheet = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("appLanguage") private var appLanguage: String = "English"
    @State private var showingLanguageSheet = false
    @State private var showingSupportSheet = false
    @State private var showingAboutSheet = false
    @State private var showNotificationsDeniedAlert = false
    
    var body: some View {
        ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                if userViewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading profile...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else if let user = userViewModel.currentUser {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Profile Header
                            profileHeader(user: user)
                            
                            // Address Section
                            addressesSection(addresses: user.addresses)
                            
                            // Orders Section
                            ordersSection(orders: userViewModel.getRecentOrders())
                            
                            // Account Settings
                            settingsSection
                            
                            // Logout Button
                            Button(action: {
                                userViewModel.signOut()
                            }) {
                                Text("Logout")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("primaryRed"))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 90)
                        }
                    }
                    .sheet(isPresented: $showingAddAddressSheet) {
                        AddAddressView()
                    }
                    .sheet(isPresented: $showingEditProfileSheet) {
                        EditProfileView(user: user)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Failed to load profile")
                            .font(.headline)
                        
                        Text("Please try logging in again or check your internet connection")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            userViewModel.checkAuthState()
                        }) {
                            Text("Retry")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 120)
                                .padding()
                                .background(Color("primaryRed"))
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            userViewModel.signOut()
                        }) {
                            Text("Sign Out")
                                .font(.subheadline)
                                .foregroundColor(Color("primaryRed"))
                        }
                        .padding(.top, 8)
                    }
                }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            syncNotificationToggleWithSystem()
            // Reload user data to get latest addresses
            userViewModel.checkAuthState()
        }
        .alert("Enable notifications in Settings", isPresented: $showNotificationsDeniedAlert) {
            Button("Open Settings") { openAppSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Notifications are turned off at the system level. Enable them in iOS Settings to receive alerts.")
        }
    }
    
    // Profile Header (modern card)
    private func profileHeader(user: User) -> some View {
        ZStack(alignment: .topTrailing) {
            // Card background with subtle gradient and soft shadow
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color("primaryYellow").opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                .overlay(
                    // Decorative glow bubbles (subtle) - centered for better balance
                    ZStack {
                        Circle()
                            .fill(Color("primaryYellow").opacity(0.15))
                            .frame(width: 140, height: 140)
                            .blur(radius: 35)
                            .offset(x: 40, y: -10)
                        Circle()
                            .fill(Color("secondaryOrange").opacity(0.1))
                            .frame(width: 110, height: 110)
                            .blur(radius: 30)
                            .offset(x: -40, y: 10)
                    }
                )
            
            // Top-right pencil quick action
            Button(action: { showingEditProfileSheet = true }) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(12)
            
            VStack(spacing: 12) {
                // Avatar with gradient ring
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 88, height: 88)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .overlay(
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [Color("primaryYellow"), Color("secondaryOrange"), Color("primaryYellow")]),
                                        center: .center
                                    ),
                                    lineWidth: 3
                                )
                        )
                    Image(systemName: "person.fill")
                        .font(.system(size: 36, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                // User Info
                VStack(spacing: 4) {
                    // Display name - handle empty cases
                    let displayName = user.fullName.isEmpty || user.fullName == "User" ? "Guest User" : user.fullName
                    Text(displayName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    if !user.email.isEmpty {
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    if !user.phone.isEmpty {
                        Text(user.phone)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Edit Profile Button (pill)
                Button(action: { showingEditProfileSheet = true }) {
                    Text("Edit Profile")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 4)
            }
            .padding(20)
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    // Addresses Section
    private func addressesSection(addresses: [Address]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Addresses")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingAddAddressSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.caption)
                        
                        Text("Add New")
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("primaryYellow"))
                    .foregroundColor(.black)
                    .cornerRadius(5)
                }
            }
            .padding(.horizontal)
            
            if addresses.isEmpty {
                Text("No addresses saved")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(addresses) { address in
                            AddressCard(address: address)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Orders Section
    private func ordersSection(orders: [Order]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(destination: OrdersView()) {
                HStack {
                    Text("My Orders")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
            }
            
            if orders.isEmpty {
                Text("No orders yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(orders.prefix(2)) { order in
                        OrderCard(order: order)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .font(.headline)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                // Notifications Setting (interactive toggle)
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.headline)
                        .foregroundColor(Color("primaryRed"))
                        .frame(width: 32)
                        .padding(.leading, 12)
                    Text("Notifications")
                        .font(.body)
                    Spacer()
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                        .onChange(of: notificationsEnabled) { _, newValue in
                            handleNotificationToggle(newValue)
                        }
                }
                .padding(.vertical, 12)
                .padding(.trailing, 16)
                
                Divider()
                    .padding(.leading, 56)
                
                // Language Setting
                Button(action: { showingLanguageSheet = true }) {
                    settingRow(icon: "globe", title: "Language", value: appLanguage)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.leading, 56)
                
                // Help & Support
                Button(action: { showingSupportSheet = true }) {
                    settingRow(icon: "questionmark.circle.fill", title: "Help & Support")
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.leading, 56)
                
                // About
                Button(action: { showingAboutSheet = true }) {
                    settingRow(icon: "info.circle.fill", title: "About")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.top, 8)
        .sheet(isPresented: $showingLanguageSheet) {
            LanguagePickerView(isPresented: $showingLanguageSheet, currentValue: appLanguage) { selected in
                appLanguage = selected
            }
        }
        .sheet(isPresented: $showingSupportSheet) {
            SupportView(isPresented: $showingSupportSheet)
        }
        .sheet(isPresented: $showingAboutSheet) {
            AboutView(isPresented: $showingAboutSheet)
        }
    }
    
    // Setting Row
    private func settingRow(icon: String, title: String, value: String? = nil, hasToggle: Bool = false) -> some View {
                    HStack {
                        Image(systemName: icon)
                            .font(.headline)
                            .foregroundColor(Color("primaryYellow"))
                            .frame(width: 32)
                            .padding(.leading, 12)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            if value != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 12)
        .padding(.trailing, 16)
    }

    // MARK: - Notifications helpers
    private func handleNotificationToggle(_ isOn: Bool) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    if isOn {
                        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                            DispatchQueue.main.async {
                                notificationsEnabled = granted
                                if !granted { showNotificationsDeniedAlert = true }
                            }
                        }
                    }
                case .denied:
                    notificationsEnabled = false
                    showNotificationsDeniedAlert = true
                default:
                    notificationsEnabled = isOn
                }
            }
        }
    }
    
    private func syncNotificationToggleWithSystem() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            }
        }
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

struct AddressCard: View {
    let address: Address
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                .multilineTextAlignment(.leading)
            
            if let landmark = address.landmark {
                Text("Landmark: \(landmark)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 250)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct OrderCard: View {
    let order: Order
    
    var body: some View {
        NavigationLink(destination: OrderDetailView(order: order)) {
            VStack(alignment: .leading, spacing: 12) {
                // Order Status & Date
                HStack {
                    Text("#\(order.id)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(order.formattedOrderDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                // Order Items
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(order.items.count) item\(order.items.count > 1 ? "s" : "")")
                            .font(.headline)
                        
                        Text("₹\(order.totalAmount, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(order.status.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(statusColor(for: order.status))
                        
                        Text(order.paymentMethod.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .confirmed:
            return .blue
        case .outForDelivery:
            return .purple
        case .delivered:
            return .green
        case .cancelled:
            return .red
        }
    }
}

struct OrdersView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        List {
            ForEach(userViewModel.orders) { order in
                OrderCard(order: order)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("My Orders")
    }
}

struct OrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss
    @State private var isExpandedItems = true
    @State private var isExpandedPayment = true
    @State private var isExpandedAddress = true
    @State private var showingSupport = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Order Status Card
                orderStatusCard
                
                // Order Items Card
                orderItemsCard
                
                // Payment Info Card
                paymentInfoCard
                
                // Delivery Address Card
                deliveryAddressCard
            }
            .padding()
        }
        .background(Color.gray.opacity(0.08).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Order Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Share order details
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { supportFooterBar }
    }
    
    // Order Status Card
    private var orderStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Order #\(order.id.prefix(8))")
                .font(.headline)
            
                Spacer()
                
                Text(dateFormatter.string(from: order.orderDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                // Order Status
                HStack(spacing: 10) {
                    Circle()
                        .fill(statusColor(for: order.status))
                        .frame(width: 10, height: 10)
                    
                    Text(order.status.rawValue)
                        .font(.subheadline)
                        .foregroundColor(statusColor(for: order.status))
                    
                    if order.status == .delivered {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.subheadline)
        }
    }
    
                // Timeline
                HStack(spacing: 0) {
                    ForEach(orderStatusTimeline, id: \.0) { status, isActive in
                        VStack(spacing: 8) {
                Circle()
                                .fill(isActive ? statusColor(for: order.status) : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                            
                            Text(status)
                .font(.caption)
                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
        .frame(width: 60)
                                .foregroundColor(isActive ? .primary : .gray)
    }
    
                        if status != orderStatusTimeline.last?.0 {
        Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [
                                                isActive ? statusColor(for: order.status) : Color.gray.opacity(0.3),
                                                getNextStatusColor(current: status)
                                            ]
                                        ),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
            .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Delivery estimate
                if order.status != .delivered && order.status != .cancelled {
                    Text("Estimated delivery by \(estimatedDeliveryTime)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // Order Items Card
    private var orderItemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header with expand/collapse
            Button(action: { withAnimation { isExpandedItems.toggle() } }) {
                HStack {
            Text("Items")
                .font(.headline)
            
                    Spacer()
                    
                    Image(systemName: isExpandedItems ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpandedItems {
                Divider()
                
                ForEach(order.items) { item in
                    HStack(alignment: .center, spacing: 16) {
                        // Item image or icon
                        Image(systemName: CategoryIconMap.iconName(for: item.product.category))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                            .frame(width: 50, height: 50)
                            .background(Color(CategoryIconMap.colorName(for: item.product.category)).opacity(0.1))
                            .cornerRadius(8)
                        
                        // Item details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(item.product.weight)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                            
                            Spacer()
                            
                        // Item price & quantity
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("₹\(item.product.discountPrice ?? item.product.price, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Qty: \(item.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                        
                        if item.id != order.items.last?.id {
                            Divider()
                        }
                    }
                }
            }
        .padding()
            .background(Color.white)
            .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // Payment Info Card
    private var paymentInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header with expand/collapse
            Button(action: { withAnimation { isExpandedPayment.toggle() } }) {
                HStack {
                    Text("Payment Information")
                .font(.headline)
            
                    Spacer()
                    
                    Image(systemName: isExpandedPayment ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpandedPayment {
                Divider()
                
                VStack(spacing: 16) {
                    // Payment method
                    HStack(spacing: 12) {
                        Text("Payment Method")
                            .font(.subheadline)
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: paymentIcon(for: order.paymentMethod))
                                .foregroundColor(.primary)
                            Text(order.paymentMethod.rawValue)
                                .font(.subheadline)
                        }
                    }
                    
                    // Items total
                    HStack {
                        Text("Items Total")
                            .font(.subheadline)
                        Spacer()
                        Text(currency(order.totalAmount - 25))
                            .font(.subheadline)
                    }
                    
                    // Delivery fee
                    HStack {
                        Text("Delivery Fee")
                            .font(.subheadline)
                        Spacer()
                        Text(currency(25))
                            .font(.subheadline)
                    }
                    
                    // GST
                    let gstAmount = order.totalAmount * 0.05
                    HStack {
                        Text("GST (5%)")
                            .font(.subheadline)
                        Spacer()
                        Text(currency(gstAmount))
                            .font(.subheadline)
                    }
                    
                    // Total amount
                    Divider()
                    HStack(alignment: .firstTextBaseline) {
                        Text("Total Amount")
                            .font(.headline)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(currency(order.totalAmount + gstAmount))
                                .font(.headline)
                            Text("(Incl. of all taxes)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // Delivery Address Card
    private var deliveryAddressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header with expand/collapse
            Button(action: { withAnimation { isExpandedAddress.toggle() } }) {
                HStack {
            Text("Delivery Address")
                .font(.headline)
            
                    Spacer()
                    
                    Image(systemName: isExpandedAddress ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
                
            if isExpandedAddress {
                Divider()
                
                HStack(alignment: .top, spacing: 16) {
                    // Address icon
                    Image(systemName: "house.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // Address title
                        Text(order.address.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        // Full address
                        Text(order.address.fullAddress)
                            .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        // Landmark (if any)
                        if let landmark = order.address.landmark {
                            Text("Landmark: \(landmark)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                    }
                }
                .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // Sticky Support Footer
    private var supportFooterBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Need help with your order?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack(spacing: 12) {
                Button(action: { showingSupport = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "ellipsis.bubble.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Contact Support")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("primaryRed"))
                    .cornerRadius(14)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
        .sheet(isPresented: $showingSupport) {
            SupportView(isPresented: $showingSupport)
        }
    }
    
    // Helper methods
    private var orderStatusTimeline: [(String, Bool)] {
        let statuses = ["Placed", "Confirmed", "Out for Delivery", "Delivered"]
        var result: [(String, Bool)] = []
        
        for status in statuses {
            let isActive: Bool = {
                switch status {
                case "Placed":
                    return true
                case "Confirmed":
                    return order.status != .pending
                case "Out for Delivery":
                    return order.status == .outForDelivery || order.status == .delivered
                case "Delivered":
                    return order.status == .delivered
                default:
                    return false
                }
            }()
            
            result.append((status, isActive))
        }
        
        return result
    }
    
    private func getNextStatusColor(current: String) -> Color {
        let nextStatus: Bool = {
            switch current {
            case "Placed":
                return order.status != .pending
            case "Confirmed":
                return order.status == .outForDelivery || order.status == .delivered
            case "Out for Delivery":
                return order.status == .delivered
            default:
                return false
            }
        }()
        
        return nextStatus ? statusColor(for: order.status) : Color.gray.opacity(0.3)
    }
    
    private func paymentIcon(for method: PaymentMethod) -> String {
        switch method {
        case .creditCard:
            return "creditcard.fill"
        case .card:
            return "creditcard.fill"
        case .upi:
            return "wallet.pass.fill"
        case .cashOnDelivery:
            return "banknote.fill"
        }
    }
    
    private func currency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "₹\(amount)"
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .confirmed:
            return .blue
        case .outForDelivery:
            return .purple
        case .delivered:
            return .green
        case .cancelled:
            return .red
        }
    }
    
    private var estimatedDeliveryTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let estimatedTime = Calendar.current.date(byAdding: .minute, value: 30, to: order.orderDate) ?? Date()
        return formatter.string(from: estimatedTime)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, h:mm a"
        return formatter
    }
}

struct AddAddressView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var title: String = ""
    @State private var fullAddress: String = ""
    @State private var landmark: String = ""
    @State private var isDefault: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Address Details")) {
                    TextField("Title (e.g., Home, Work)", text: $title)
                    
                    TextField("Full Address", text: $fullAddress)
                        .frame(height: 80)
                    
                    TextField("Landmark (Optional)", text: $landmark)
                }
                
                Section {
                    Toggle("Set as Default Address", isOn: $isDefault)
                }
                
                Section {
                    Button(action: saveAddress) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save Address")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(title.isEmpty || fullAddress.isEmpty || isLoading)
                }
            }
            .navigationTitle("Add New Address")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
    
    private func saveAddress() {
        isLoading = true
        
        userViewModel.addAddress(
            title: title,
            fullAddress: fullAddress,
            landmark: landmark.isEmpty ? nil : landmark
        ) { success in
            isLoading = false
            
            if success {
                dismiss()
            }
        }
    }
}

struct EditProfileView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    
    init(user: User) {
        self.user = user
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName)
        _email = State(initialValue: user.email)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    
                    HStack {
                        Text("Phone")
                        Spacer()
                        Text(user.phone)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: updateProfile) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Update Profile")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty || isLoading)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
    
    private func updateProfile() {
        isLoading = true
        
        userViewModel.updateProfile(
            firstName: firstName,
            lastName: lastName,
            email: email
        ) { success in
            isLoading = false
            
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserViewModel())
} 

// MARK: - Language Picker
struct LanguagePickerView: View {
    @Binding var isPresented: Bool
    var currentValue: String
    var onSelect: (String) -> Void
    private let languages = ["English", "Hindi", "Telugu", "Tamil", "Kannada", "Marathi", "Bengali"]
    
    var body: some View {
        NavigationView {
            List(languages, id: \.self) { lang in
                HStack {
                    Text(lang)
                    Spacer()
                    if lang == currentValue { Image(systemName: "checkmark") }
                }
                .contentShape(Rectangle())
                .onTapGesture { onSelect(lang) }
            }
            .navigationTitle("Language")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isPresented = false }
                }
            }
        }
    }
}

// MARK: - Support View
struct SupportView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How can we help?")
                    .font(.headline)
                
                Button(action: { openURL("mailto:support@quickshop.local") }) {
                    Label("Email Support", systemImage: "envelope.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("primaryRed"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { openURL("tel://1800123456") }) {
                    Label("Call Support", systemImage: "phone.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Help & Support")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { isPresented = false } } }
        }
    }
    
    private func openURL(_ string: String) {
        if let url = URL(string: string) { UIApplication.shared.open(url) }
    }
}

// MARK: - About View
struct AboutView: View {
    @Binding var isPresented: Bool
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App")
                    .font(.title3).bold()
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
                let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
                Text("Version \(version) (\(build))")
                    .foregroundColor(.secondary)
                Text("QuickShop is a demo grocery delivery app built with SwiftUI.")
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding()
            .navigationTitle("About")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { isPresented = false } } }
        }
    }
}