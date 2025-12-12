import Foundation
import MapKit
import Combine

/// ViewModel for handling address search with autocomplete
class AddressSearchViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var selectedAddress: String = ""
    @Published var isSearching: Bool = false
    
    // MARK: - Private Properties
    private let searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    override init() {
        super.init()
        setupSearchCompleter()
        setupSearchTextBinding()
    }
    
    // MARK: - Setup
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        
        // Focus on India region for better results
        let indiaRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
            span: MKCoordinateSpan(latitudeDelta: 30.0, longitudeDelta: 30.0)
        )
        searchCompleter.region = indiaRegion
    }
    
    private func setupSearchTextBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.performSearch(query: text)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Search
    private func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        searchCompleter.queryFragment = trimmedQuery
    }
    
    /// Clear search
    func clearSearch() {
        searchText = ""
        searchResults = []
        selectedLocation = nil
        selectedAddress = ""
    }
    
    // MARK: - Select Result
    /// Select a search result and get its coordinate
    func selectResult(_ completion: MKLocalSearchCompletion, handler: @escaping (CLLocationCoordinate2D?, String?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Search error: \(error.localizedDescription)")
                    handler(nil, nil)
                    return
                }
                
                guard let mapItem = response?.mapItems.first else {
                    handler(nil, nil)
                    return
                }
                
                let coordinate = mapItem.placemark.coordinate
                let address = self.formatAddress(from: mapItem.placemark)
                
                self.selectedLocation = coordinate
                self.selectedAddress = address
                self.searchResults = []
                
                print("📍 Selected: \(address) at (\(coordinate.latitude), \(coordinate.longitude))")
                handler(coordinate, address)
            }
        }
    }
    
    // MARK: - Format Address
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var parts: [String] = []
        
        if let subThoroughfare = placemark.subThoroughfare {
            parts.append(subThoroughfare)
        }
        if let thoroughfare = placemark.thoroughfare {
            parts.append(thoroughfare)
        }
        if let subLocality = placemark.subLocality {
            parts.append(subLocality)
        }
        if let locality = placemark.locality {
            parts.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            parts.append(administrativeArea)
        }
        
        return parts.joined(separator: ", ")
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension AddressSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.isSearching = false
            self.searchResults = completer.results
            print("🔍 Found \(completer.results.count) results")
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isSearching = false
            print("❌ Completer error: \(error.localizedDescription)")
        }
    }
}
