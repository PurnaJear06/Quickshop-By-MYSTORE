import Foundation
import CoreLocation

/// Represents a dark store (micro-warehouse) for quick delivery
struct DarkStore: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let serviceableRadius: Double  // in km (default 3.0)
    let isActive: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Calculate distance to a coordinate in kilometers
    func distance(to location: CLLocationCoordinate2D) -> Double {
        let storeLocation = CLLocation(latitude: latitude, longitude: longitude)
        let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return storeLocation.distance(from: targetLocation) / 1000 // Convert meters to km
    }
    
    /// Check if a location is within the serviceable area
    func isServiceable(location: CLLocationCoordinate2D) -> Bool {
        return distance(to: location) <= serviceableRadius
    }
}

// MARK: - Sample Data
extension DarkStore {
    /// Sample dark stores for Bengaluru
    static var sampleStores: [DarkStore] {
        [
            DarkStore(
                id: "store_koramangala",
                name: "QuickShop Koramangala",
                address: "Koramangala 4th Block, Bengaluru, Karnataka",
                latitude: 12.9352,
                longitude: 77.6245,
                serviceableRadius: 10.0,
                isActive: true
            ),
            DarkStore(
                id: "store_hsr",
                name: "QuickShop HSR Layout",
                address: "HSR Layout Sector 2, Bengaluru, Karnataka",
                latitude: 12.9121,
                longitude: 77.6446,
                serviceableRadius: 10.0,
                isActive: true
            ),
            DarkStore(
                id: "store_indiranagar",
                name: "QuickShop Indiranagar",
                address: "Indiranagar 100 Feet Road, Bengaluru, Karnataka",
                latitude: 12.9719,
                longitude: 77.6412,
                serviceableRadius: 10.0,
                isActive: true
            ),
            DarkStore(
                id: "store_whitefield",
                name: "QuickShop Whitefield",
                address: "Whitefield Main Road, Bengaluru, Karnataka",
                latitude: 12.9698,
                longitude: 77.7500,
                serviceableRadius: 10.0,
                isActive: true
            ),
            DarkStore(
                id: "store_jpnagar",
                name: "QuickShop JP Nagar",
                address: "JP Nagar 6th Phase, Bengaluru, Karnataka",
                latitude: 12.9063,
                longitude: 77.5857,
                serviceableRadius: 10.0,
                isActive: true
            ),
            DarkStore(
                id: "store_kondapur",
                name: "QuickShop Kondapur",
                address: "Kondapur, Hyderabad, Telangana",
                latitude: 17.4639,
                longitude: 78.3489,
                serviceableRadius: 10.0,
                isActive: true
            )
        ]
    }
}
