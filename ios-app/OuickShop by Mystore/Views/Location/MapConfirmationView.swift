import SwiftUI
import MapKit
import CoreLocation

/// Screen 2: Map Confirmation View (Blinkit-style)
struct MapConfirmationView: View {
    @Binding var isPresented: Bool
    @Binding var parentPresented: Bool
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var deliveryService = DeliveryService.shared
    @StateObject private var searchViewModel = AddressSearchViewModel()
    
    // Initial values from AddressListView
    var initialCoordinate: CLLocationCoordinate2D?
    var initialAddress: String
    
    // Map State
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
    @State private var selectedAddress: String = ""
    @State private var selectedArea: String = ""
    @State private var isLoadingAddress: Bool = false
    @State private var mapMoving: Bool = false
    @State private var showTooltip: Bool = true
    
    // Search
    @State private var showSearchResults: Bool = false
    
    // Delivery Contact
    @State private var recipientName: String = ""
    @State private var recipientPhone: String = ""
    
    // Recent Searches
    @StateObject private var recentSearches = RecentSearchesManager.shared
    
    // Save Address
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showSaveSheet: Bool = false
    
    // Confirmation
    @State private var isConfirming: Bool = false
    
    var body: some View {
        ZStack {
            // MARK: - Full Screen Map
            MapReader { proxy in
                Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
                    // Dark store markers
                    ForEach(deliveryService.darkStores) { store in
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)) {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 8, height: 8)
                                )
                        }
                    }
                }
                .onMapCameraChange(frequency: .continuous) { context in
                    mapMoving = true
                    showTooltip = true
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    mapCenter = context.camera.centerCoordinate
                    mapMoving = false
                    updateAddress(for: context.camera.centerCoordinate)
                }
            }
            .ignoresSafeArea()
            
            // MARK: - Center Pin
            VStack {
                Spacer()
                
                // Pin with tooltip
                VStack(spacing: 0) {
                    // Tooltip
                    if showTooltip {
                        Text("Move the pin to adjust your location")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.8))
                            )
                            .offset(y: 8)
                            .transition(.opacity.combined(with: .scale))
                    }
                    
                    // Pin
                    ZStack {
                        // Outer ring
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        // Inner pin
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                            )
                    }
                    .offset(y: mapMoving ? -8 : 0)
                    .animation(.spring(response: 0.3), value: mapMoving)
                    
                    // Shadow dot
                    Ellipse()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 20, height: 6)
                        .offset(y: 4)
                }
                
                Spacer()
            }
            
            // MARK: - Top Section
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Confirm map pin location")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible spacer for centering
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                
                // Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for area, street name...", text: $searchViewModel.searchText)
                        .font(.system(size: 15))
                        .onChange(of: searchViewModel.searchText) { _, newValue in
                            showSearchResults = !newValue.isEmpty
                        }
                    
                    if !searchViewModel.searchText.isEmpty {
                        Button(action: {
                            searchViewModel.clearSearch()
                            showSearchResults = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Search Results
                if showSearchResults && !searchViewModel.searchResults.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(searchViewModel.searchResults, id: \.self) { result in
                                Button(action: { selectSearchResult(result) }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "mappin.circle")
                                            .foregroundColor(Color("primaryGreen"))
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(result.title)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                            Text(result.subtitle)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider().padding(.leading, 44)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
            
            // MARK: - Bottom Card
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // "Go to current location" button
                    Button(action: goToCurrentLocation) {
                        HStack(spacing: 8) {
                            Image(systemName: "location.circle")
                                .font(.system(size: 16))
                            Text("Go to current location")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(Color("primaryGreen"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .stroke(Color("primaryGreen"), lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 8)
                    
                    // Delivery info card
                    VStack(spacing: 0) {
                        // Address section
                        HStack(alignment: .top, spacing: 12) {
                            // Location icon
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "location.fill")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16))
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Delivering your order to")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                if isLoadingAddress {
                                    HStack(spacing: 6) {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                        Text("Finding address...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    Text(selectedArea.isEmpty ? "Select location" : selectedArea)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Text(selectedAddress)
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { isPresented = false }) {
                                Text("Change")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("primaryGreen"))
                            }
                        }
                        .padding(16)
                        
                        // MARK: - Serviceable Content
                        if deliveryService.isServiceable {
                            // Delivery contact fields
                            VStack(spacing: 12) {
                                // Recipient Name
                                HStack(spacing: 12) {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    TextField("Recipient name", text: $recipientName)
                                        .font(.system(size: 15))
                                }
                                .padding(14)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(10)
                                
                                // Recipient Phone
                                HStack(spacing: 12) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    TextField("Phone number", text: $recipientPhone)
                                        .font(.system(size: 15))
                                        .keyboardType(.phonePad)
                                }
                                .padding(14)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            
                            // Store info
                            if let store = deliveryService.nearestStore {
                                HStack(spacing: 8) {
                                    Image(systemName: "storefront.fill")
                                        .foregroundColor(Color("primaryGreen"))
                                        .font(.system(size: 12))
                                    Text("Delivering from \(store.name)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("\(deliveryService.estimatedDeliveryTime) min")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color("primaryGreen"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                            }
                            
                            // Confirm button
                            Button(action: confirmLocation) {
                                HStack(spacing: 8) {
                                    if isConfirming {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.9)
                                    } else {
                                        Text("Confirm location")
                                            .font(.system(size: 16, weight: .semibold))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    (recipientName.isEmpty || recipientPhone.isEmpty) ?
                                    Color.gray.opacity(0.4) :
                                    Color("primaryGreen")
                                )
                                .cornerRadius(12)
                            }
                            .disabled(recipientName.isEmpty || recipientPhone.isEmpty || isConfirming)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            
                        } else {
                            // MARK: - Not Serviceable Card
                            VStack(spacing: 16) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "location.slash.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.orange)
                                }
                                
                                Text("We're not in your area yet!")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                if let store = deliveryService.nearestStore {
                                    Text("Nearest store is \(String(format: "%.1f", deliveryService.distanceToStore)) km away")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                // Notify button
                                Button(action: {}) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 14))
                                        Text("Notify me when available")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color("primaryYellow"))
                                    .cornerRadius(10)
                                }
                                
                                // Try another location
                                Button(action: { isPresented = false }) {
                                    Text("Try another location")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("primaryGreen"))
                                        .underline()
                                }
                            }
                            .padding(20)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            setupInitialState()
        }
        .sheet(isPresented: $showSaveSheet) {
            SaveAddressSheet(
                isPresented: $showSaveSheet,
                address: selectedAddress,
                coordinate: mapCenter
            )
            .environmentObject(userViewModel)
        }
    }
    
    // MARK: - Methods
    private func setupInitialState() {
        let coordinate = initialCoordinate ?? CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        cameraPosition = .region(region)
        mapCenter = coordinate
        
        if !initialAddress.isEmpty {
            selectedAddress = initialAddress
            // Extract area name
            let parts = initialAddress.components(separatedBy: ",")
            selectedArea = parts.first ?? initialAddress
        }
        
        // Force calculate on initial load
        deliveryService.forceCalculateDelivery(for: coordinate)
        updateAddress(for: coordinate)
        
        // Hide tooltip after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showTooltip = false
            }
        }
    }
    
    private func updateAddress(for coordinate: CLLocationCoordinate2D) {
        isLoadingAddress = true
        
        // Update ETA
        deliveryService.calculateDelivery(for: coordinate)
        
        // Reverse geocode
        locationManager.reverseGeocode(coordinate: coordinate) { address in
            DispatchQueue.main.async {
                self.isLoadingAddress = false
                if let fullAddress = address {
                    self.selectedAddress = fullAddress
                    // Extract first part as area
                    let parts = fullAddress.components(separatedBy: ",")
                    self.selectedArea = parts.first?.trimmingCharacters(in: .whitespaces) ?? fullAddress
                } else {
                    self.selectedAddress = "Unable to find address"
                    self.selectedArea = "Unknown"
                }
            }
        }
    }
    
    private func goToCurrentLocation() {
        locationManager.requestCurrentLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let location = locationManager.location {
                withAnimation(.easeInOut(duration: 0.5)) {
                    let region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                    cameraPosition = .region(region)
                    mapCenter = location.coordinate
                }
                updateAddress(for: location.coordinate)
            }
        }
    }
    
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        searchViewModel.selectResult(result) { coordinate, address in
            if let coord = coordinate {
                withAnimation(.easeInOut(duration: 0.5)) {
                    let region = MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                    cameraPosition = .region(region)
                    mapCenter = coord
                }
                if let addr = address {
                    selectedAddress = addr
                    selectedArea = result.title
                }
                deliveryService.calculateDelivery(for: coord)
            }
            showSearchResults = false
            searchViewModel.searchText = ""
        }
    }
    
    private func confirmLocation() {
        guard deliveryService.isServiceable else { return }
        guard !recipientName.isEmpty && !recipientPhone.isEmpty else { return }
        
        isConfirming = true
        
        // Save to DeliveryService
        deliveryService.calculateDelivery(for: mapCenter)
        
        // Save to recent searches
        recentSearches.saveSearch(address: selectedAddress, coordinate: mapCenter)
        
        print("📍 Confirmed: \(selectedAddress)")
        print("👤 Recipient: \(recipientName), 📞 \(recipientPhone)")
        print("⏱️ ETA: \(deliveryService.estimatedDeliveryTime) minutes")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isConfirming = false
            // Show save sheet to optionally save the address
            showSaveSheet = true
        }
    }
    
    private func dismissAll() {
        isPresented = false
        parentPresented = false
    }
}

#Preview {
    MapConfirmationView(
        isPresented: .constant(true),
        parentPresented: .constant(true),
        initialCoordinate: nil,
        initialAddress: ""
    )
}
