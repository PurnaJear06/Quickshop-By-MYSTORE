import SwiftUI
import MapKit
import CoreLocation

/// Modern Blinkit/Zepto style Location Picker with MapKit
struct LocationPickerMapView: View {
    @Binding var isPresented: Bool
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var deliveryService = DeliveryService.shared
    @StateObject private var searchViewModel = AddressSearchViewModel()
    
    // Map State
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    ))
    @State private var mapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
    @State private var selectedAddress: String = "Move the map to select location"
    @State private var isLoadingAddress: Bool = false
    
    // Delivery Contact Fields
    @State private var recipientName: String = ""
    @State private var recipientPhone: String = ""
    @State private var addressLabel: String = "Home"
    
    // UI State
    @State private var showSearchResults: Bool = false
    @State private var isConfirming: Bool = false
    @State private var mapMoving: Bool = false
    
    var body: some View {
        ZStack {
            // MARK: - Full Screen Map
            MapReader { proxy in
                Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
                    // Dark store markers
                    ForEach(deliveryService.darkStores) { store in
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)) {
                            ZStack {
                                Circle()
                                    .fill(Color("primaryGreen").opacity(0.2))
                                    .frame(width: 30, height: 30)
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("primaryGreen"))
                            }
                        }
                    }
                }
                .onMapCameraChange(frequency: .continuous) { context in
                    mapCenter = context.camera.centerCoordinate
                    mapMoving = true
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    mapCenter = context.camera.centerCoordinate
                    mapMoving = false
                    updateAddressAndETA(for: context.camera.centerCoordinate)
                }
            }
            .ignoresSafeArea()
            
            // MARK: - Center Pin (Fixed in center)
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    // Pin head
                    ZStack {
                        Circle()
                            .fill(Color("primaryGreen"))
                            .frame(width: 24, height: 24)
                        Circle()
                            .fill(.white)
                            .frame(width: 10, height: 10)
                    }
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    // Pin stem
                    Rectangle()
                        .fill(Color("primaryGreen"))
                        .frame(width: 3, height: 20)
                    
                    // Pin shadow
                    Ellipse()
                        .fill(.black.opacity(0.2))
                        .frame(width: 16, height: 6)
                        .offset(y: -2)
                }
                .offset(y: mapMoving ? -10 : 0)
                .animation(.spring(response: 0.3), value: mapMoving)
                
                Spacer()
            }
            
            // MARK: - Top Overlay (Header + Search)
            VStack(spacing: 0) {
                // Gradient Header
                LinearGradient(
                    colors: [Color("primaryYellow"), Color("primaryYellow").opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .overlay(
                    VStack(spacing: 8) {
                        Spacer()
                        HStack {
                            Button(action: { isPresented = false }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .background(Circle().fill(.white))
                            }
                            
                            Spacer()
                            
                            Text("Select Location")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            // GPS Button
                            Button(action: centerOnCurrentLocation) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("primaryGreen"))
                                    .padding(10)
                                    .background(Circle().fill(.white))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                )
                .ignoresSafeArea(edges: .top)
                
                // Search Bar
                HStack(spacing: 12) {
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
                .padding(14)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
                .offset(y: -20)
                
                // Search Results
                if showSearchResults && !searchViewModel.searchResults.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(searchViewModel.searchResults, id: \.self) { result in
                                Button(action: {
                                    selectSearchResult(result)
                                }) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color("primaryYellow").opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "mappin")
                                                .foregroundColor(Color("primaryGreen"))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(result.title)
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                            Text(result.subtitle)
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.up.left")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                }
                                
                                if result != searchViewModel.searchResults.last {
                                    Divider().padding(.leading, 68)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .offset(y: -16)
                }
                
                Spacer()
            }
            
            // MARK: - Bottom Card
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Handle bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                    
                    VStack(spacing: 16) {
                        // Delivery Time Banner
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(deliveryService.isServiceable ? Color("primaryYellow") : .orange)
                                
                                if deliveryService.isServiceable {
                                    Text("\(deliveryService.estimatedDeliveryTime) min delivery")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color("primaryGreen"))
                                } else {
                                    Text("Out of delivery area")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Spacer()
                            
                            if deliveryService.distanceToStore > 0 {
                                Text(deliveryService.formattedDistance())
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(
                            deliveryService.isServiceable ?
                            Color("primaryYellow").opacity(0.15) :
                            Color.orange.opacity(0.1)
                        )
                        .cornerRadius(10)
                        
                        // Selected Address
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color("primaryGreen").opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "location.fill")
                                    .foregroundColor(Color("primaryGreen"))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if isLoadingAddress {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                        Text("Finding address...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    Text(selectedAddress)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Address Label Pills
                        HStack(spacing: 10) {
                            ForEach(["Home", "Work", "Other"], id: \.self) { label in
                                Button(action: { addressLabel = label }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: label == "Home" ? "house.fill" : label == "Work" ? "briefcase.fill" : "mappin.circle.fill")
                                            .font(.system(size: 12))
                                        Text(label)
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(addressLabel == label ? .white : .black)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        addressLabel == label ?
                                        Color("primaryGreen") :
                                        Color.gray.opacity(0.1)
                                    )
                                    .cornerRadius(20)
                                }
                            }
                            Spacer()
                        }
                        
                        // Name and Phone
                        VStack(spacing: 10) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(Color("primaryGreen"))
                                    .frame(width: 20)
                                TextField("Recipient Name", text: $recipientName)
                                    .font(.system(size: 15))
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.06))
                            .cornerRadius(10)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(Color("primaryGreen"))
                                    .frame(width: 20)
                                TextField("Phone Number", text: $recipientPhone)
                                    .font(.system(size: 15))
                                    .keyboardType(.phonePad)
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.06))
                            .cornerRadius(10)
                        }
                        
                        // Confirm Button
                        Button(action: confirmLocation) {
                            HStack(spacing: 8) {
                                if isConfirming {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                    Text("CONFIRM LOCATION")
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                deliveryService.isServiceable ?
                                Color("primaryYellow") :
                                Color.gray.opacity(0.3)
                            )
                            .cornerRadius(12)
                        }
                        .disabled(!deliveryService.isServiceable || isConfirming)
                    }
                    .padding(20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: -5)
                )
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            setupInitialLocation()
        }
    }
    
    // MARK: - Methods
    private func setupInitialLocation() {
        locationManager.requestPermission()
        
        // Wait for location
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let location = locationManager.location {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                )
                cameraPosition = .region(region)
                mapCenter = location.coordinate
                updateAddressAndETA(for: location.coordinate)
            } else {
                // Use default and calculate
                updateAddressAndETA(for: mapCenter)
            }
        }
    }
    
    private func centerOnCurrentLocation() {
        locationManager.requestCurrentLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let location = locationManager.location {
                withAnimation(.easeInOut(duration: 0.5)) {
                    let region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                    )
                    cameraPosition = .region(region)
                    mapCenter = location.coordinate
                }
                updateAddressAndETA(for: location.coordinate)
            }
        }
    }
    
    private func updateAddressAndETA(for coordinate: CLLocationCoordinate2D) {
        isLoadingAddress = true
        
        // Update ETA
        deliveryService.calculateDelivery(for: coordinate)
        
        // Reverse geocode
        locationManager.reverseGeocode(coordinate: coordinate) { address in
            DispatchQueue.main.async {
                self.isLoadingAddress = false
                self.selectedAddress = address ?? "Unable to find address"
            }
        }
    }
    
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        searchViewModel.selectResult(result) { coordinate, address in
            if let coord = coordinate {
                withAnimation(.easeInOut(duration: 0.5)) {
                    let region = MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                    )
                    cameraPosition = .region(region)
                    mapCenter = coord
                }
                if let addr = address {
                    selectedAddress = addr
                }
                deliveryService.calculateDelivery(for: coord)
            }
            showSearchResults = false
            searchViewModel.searchText = ""
        }
    }
    
    private func confirmLocation() {
        guard deliveryService.isServiceable else { return }
        
        isConfirming = true
        
        print("📍 Confirmed: \(selectedAddress)")
        print("👤 Recipient: \(recipientName), \(recipientPhone)")
        print("🏷️ Label: \(addressLabel)")
        print("⏱️ ETA: \(deliveryService.estimatedDeliveryTime) minutes")
        
        // Calculate delivery for confirmed location
        deliveryService.calculateDelivery(for: mapCenter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isConfirming = false
            isPresented = false
        }
    }
}

// MARK: - Preview
#Preview {
    LocationPickerMapView(isPresented: .constant(true))
}
