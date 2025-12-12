import Foundation
import CoreLocation

/// Represents a recently searched address
struct RecentSearch: Identifiable, Codable, Equatable {
    let id: String
    let address: String
    let latitude: Double
    let longitude: Double
    let searchDate: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func == (lhs: RecentSearch, rhs: RecentSearch) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Manages recent address searches with persistence
class RecentSearchesManager: ObservableObject {
    // MARK: - Published Properties
    @Published var recentSearches: [RecentSearch] = []
    
    // MARK: - Constants
    private let maxRecents = 5
    private let userDefaultsKey = "quickshop_recent_searches"
    
    // MARK: - Singleton
    static let shared = RecentSearchesManager()
    
    // MARK: - Init
    init() {
        loadRecentSearches()
    }
    
    // MARK: - Save Search
    /// Save a new address search
    func saveSearch(address: String, coordinate: CLLocationCoordinate2D) {
        let newSearch = RecentSearch(
            id: UUID().uuidString,
            address: address,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            searchDate: Date()
        )
        
        // Remove any existing entry with same address (avoid duplicates)
        recentSearches.removeAll { 
            $0.address.lowercased() == address.lowercased() 
        }
        
        // Insert at beginning (most recent first)
        recentSearches.insert(newSearch, at: 0)
        
        // Keep only max items
        if recentSearches.count > maxRecents {
            recentSearches = Array(recentSearches.prefix(maxRecents))
        }
        
        saveToUserDefaults()
        print("💾 Saved recent search: \(address)")
    }
    
    // MARK: - Remove Search
    /// Remove a specific search
    func removeSearch(_ search: RecentSearch) {
        recentSearches.removeAll { $0.id == search.id }
        saveToUserDefaults()
    }
    
    // MARK: - Clear All
    /// Clear all recent searches
    func clearAll() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("🗑️ Cleared all recent searches")
    }
    
    // MARK: - Persistence
    /// Load from UserDefaults
    private func loadRecentSearches() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("📭 No recent searches found")
            return
        }
        
        do {
            let searches = try JSONDecoder().decode([RecentSearch].self, from: data)
            recentSearches = searches
            print("📂 Loaded \(searches.count) recent searches")
        } catch {
            print("❌ Failed to decode recent searches: \(error)")
        }
    }
    
    /// Save to UserDefaults
    private func saveToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(recentSearches)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("❌ Failed to encode recent searches: \(error)")
        }
    }
}
