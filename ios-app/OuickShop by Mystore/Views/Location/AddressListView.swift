import SwiftUI
import CoreLocation
import MapKit

/// Screen 1: Address List View (Blinkit-style)
struct AddressListView: View {
    @Binding var isPresented: Bool
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var searchViewModel = AddressSearchViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var recentSearches = RecentSearchesManager.shared
    
    @State private var showMapConfirmation = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedAddress: String = ""
    @State private var showSearchResults = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Search Bar
                searchBarView
                
                // Search Results
                if showSearchResults && !searchViewModel.searchResults.isEmpty {
                    searchResultsView
                } else {
                    // Main Content
                    ScrollView {
                        VStack(spacing: 0) {
                            // Quick Actions
                            quickActionsView
                            
                            // Recent Searches (if any)
                            if !recentSearches.recentSearches.isEmpty {
                                recentSearchesView
                            }
                            
                            // Divider
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 8)
                            
                            // Saved Addresses
                            savedAddressesView
                        }
                    }
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showMapConfirmation) {
                MapConfirmationView(
                    isPresented: $showMapConfirmation,
                    parentPresented: $isPresented,
                    initialCoordinate: selectedCoordinate,
                    initialAddress: selectedAddress
                )
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("Select delivery location")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Circle().fill(Color.gray.opacity(0.1)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Search Bar
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 18))
            
            TextField("Search for area, street name...", text: $searchViewModel.searchText)
                .font(.system(size: 16))
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
        .background(Color.gray.opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    // MARK: - Search Results
    private var searchResultsView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(searchViewModel.searchResults, id: \.self) { result in
                    Button(action: {
                        selectSearchResult(result)
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color("primaryGreen").opacity(0.1))
                                    .frame(width: 44, height: 44)
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
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider().padding(.leading, 78)
                }
            }
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsView: some View {
        VStack(spacing: 0) {
            // Use Current Location
            Button(action: useCurrentLocation) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .stroke(Color("primaryGreen"), lineWidth: 1.5)
                            .frame(width: 44, height: 44)
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color("primaryGreen"))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Use your current location")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("primaryGreen"))
                        
                        if !locationManager.lastKnownAddress.isEmpty {
                            Text(locationManager.lastKnownAddress)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            }
            
            Divider().padding(.leading, 78)
            
            // Add New Address
            Button(action: addNewAddress) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("primaryGreen"))
                    }
                    
                    Text("Add new address")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("primaryGreen"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            }
            
            Divider().padding(.leading, 78)
            
            // Request from Someone (WhatsApp)
            Button(action: {}) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "message.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                    }
                    
                    Text("Request address from someone else")
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Recent Searches
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Recent searches")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: { recentSearches.clearAll() }) {
                    Text("Clear all")
                        .font(.system(size: 13))
                        .foregroundColor(Color("primaryGreen"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Recent items
            ForEach(recentSearches.recentSearches) { search in
                Button(action: { selectRecentSearch(search) }) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        
                        Text(search.address)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Delete button
                        Button(action: { recentSearches.removeSearch(search) }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .padding(6)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Saved Addresses
    private var savedAddressesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your saved addresses")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            if let user = userViewModel.currentUser {
                ForEach(user.addresses) { address in
                    savedAddressCard(address: address)
                }
            }
            
            // Fallback: Show sample if no addresses
            if userViewModel.currentUser?.addresses.isEmpty ?? true {
                Text("No saved addresses yet")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
            }
        }
    }
    
    // MARK: - Saved Address Card
    private func savedAddressCard(address: Address) -> some View {
        Button(action: {
            selectSavedAddress(address)
        }) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(address.labelColor).opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: address.labelIcon)
                            .font(.system(size: 18))
                            .foregroundColor(Color(address.labelColor))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Title + Distance
                        HStack {
                            Text(address.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            // Calculate distance
                            if let location = locationManager.location {
                                let addressCoord = CLLocationCoordinate2D(
                                    latitude: address.latitude,
                                    longitude: address.longitude
                                )
                                let distance = calculateDistance(from: location.coordinate, to: addressCoord)
                                
                                Text(formatDistance(distance))
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("primaryGreen"))
                            }
                        }
                        
                        // Full Address
                        Text(address.fullAddress)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Landmark
                        if let landmark = address.landmark, !landmark.isEmpty {
                            Text("Near: \(landmark)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(10)
                            .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(10)
                            .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 78)
                .padding(.bottom, 16)
                
                Divider()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Actions
    private func useCurrentLocation() {
        locationManager.requestCurrentLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let location = locationManager.location {
                selectedCoordinate = location.coordinate
                selectedAddress = locationManager.lastKnownAddress
                showMapConfirmation = true
            } else {
                // Default to Bengaluru
                selectedCoordinate = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
                showMapConfirmation = true
            }
        }
    }
    
    private func addNewAddress() {
        if let location = locationManager.location {
            selectedCoordinate = location.coordinate
        } else {
            selectedCoordinate = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
        }
        selectedAddress = ""
        showMapConfirmation = true
    }
    
    private func selectSavedAddress(_ address: Address) {
        if address.latitude != 0 && address.longitude != 0 {
            selectedCoordinate = CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude)
            selectedAddress = address.fullAddress
            showMapConfirmation = true
        }
    }
    
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        searchViewModel.selectResult(result) { coordinate, address in
            if let coord = coordinate {
                selectedCoordinate = coord
                selectedAddress = address ?? result.title
                showMapConfirmation = true
            }
        }
    }
    
    private func selectRecentSearch(_ search: RecentSearch) {
        selectedCoordinate = search.coordinate
        selectedAddress = search.address
        showMapConfirmation = true
    }
    
    // MARK: - Helpers
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) // in meters
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0f m away", meters)
        } else {
            return String(format: "%.2f km away", meters / 1000)
        }
    }
}

#Preview {
    AddressListView(isPresented: .constant(true))
        .environmentObject(UserViewModel())
}
