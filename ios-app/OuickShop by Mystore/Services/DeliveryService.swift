import Foundation
import CoreLocation
import Combine

/// Service for calculating delivery ETA and managing dark stores
class DeliveryService: ObservableObject {
    // MARK: - Published Properties
    @Published var nearestStore: DarkStore?
    @Published var distanceToStore: Double = 0.0
    @Published var estimatedDeliveryTime: Int = 9  // in minutes
    @Published var isServiceable: Bool = true
    @Published var darkStores: [DarkStore] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Constants
    private let basePreparationTime: Int = 5  // minutes to pick & pack
    private let travelSpeedKmPerMin: Double = 0.3  // ~18 km/h average speed
    private let minimumDeliveryTime: Int = 6
    private let maximumServiceableRadius: Double = 10.0  // km - expanded delivery range
    
    // MARK: - Debouncing & Caching
    private var lastCalculatedCoordinate: CLLocationCoordinate2D?
    private var lastCalculationTime: Date = .distantPast
    private let minimumCalculationInterval: TimeInterval = 0.5  // 500ms debounce
    
    // MARK: - Singleton
    static let shared = DeliveryService()
    
    // MARK: - Init
    init() {
        loadDarkStores()
    }
    
    // MARK: - Load Dark Stores
    /// Load dark stores (from sample data for now, later from Firestore)
    func loadDarkStores() {
        isLoading = true
        // TODO: Load from Firestore in production
        self.darkStores = DarkStore.sampleStores.filter { $0.isActive }
        isLoading = false
        print("📍 Loaded \(darkStores.count) dark stores")
    }
    
    // MARK: - Calculate Delivery
    /// Calculate delivery details for a given coordinate (with debouncing)
    func calculateDelivery(for coordinate: CLLocationCoordinate2D) {
        // Debounce: Skip if called too recently
        let now = Date()
        if now.timeIntervalSince(lastCalculationTime) < minimumCalculationInterval {
            return
        }
        
        // Skip if coordinate hasn't changed significantly (within ~10 meters)
        if let lastCoord = lastCalculatedCoordinate {
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                .distance(from: CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude))
            if distance < 10 {
                return
            }
        }
        
        lastCalculationTime = now
        lastCalculatedCoordinate = coordinate
        
        guard !darkStores.isEmpty else {
            isServiceable = false
            estimatedDeliveryTime = 0
            print("❌ No dark stores available")
            return
        }
        
        // Find nearest active store
        let sortedStores = darkStores
            .sorted { $0.distance(to: coordinate) < $1.distance(to: coordinate) }
        
        guard let nearest = sortedStores.first else {
            isServiceable = false
            print("❌ No nearest store found")
            return
        }
        
        nearestStore = nearest
        distanceToStore = nearest.distance(to: coordinate)
        
        // Check if within serviceable radius
        isServiceable = distanceToStore <= nearest.serviceableRadius
        
        // Calculate ETA
        if isServiceable {
            estimatedDeliveryTime = calculateETA(distance: distanceToStore)
            print("✅ Delivery: \(estimatedDeliveryTime) min, \(String(format: "%.2f", distanceToStore)) km from \(nearest.name)")
        } else {
            estimatedDeliveryTime = 0
            print("❌ Out of range: \(String(format: "%.2f", distanceToStore)) km")
        }
    }
    
    /// Force recalculate without debouncing (for initial load)
    func forceCalculateDelivery(for coordinate: CLLocationCoordinate2D) {
        lastCalculationTime = .distantPast
        lastCalculatedCoordinate = nil
        calculateDelivery(for: coordinate)
    }
    
    // MARK: - ETA Calculation
    /// Calculate estimated delivery time based on distance
    /// Formula: ETA = Preparation Time + Travel Time
    private func calculateETA(distance: Double) -> Int {
        let travelTimeMinutes = distance / travelSpeedKmPerMin
        let totalTime = Double(basePreparationTime) + travelTimeMinutes
        
        // Round up and ensure minimum time
        let roundedTime = Int(ceil(totalTime))
        return max(minimumDeliveryTime, roundedTime)
    }
    
    // MARK: - Formatted Output
    /// Get formatted ETA string for display
    func formattedETA() -> String {
        if !isServiceable {
            return "Not available"
        }
        return "\(estimatedDeliveryTime) minutes"
    }
    
    /// Get formatted distance string
    func formattedDistance() -> String {
        if distanceToStore < 1.0 {
            return "\(Int(distanceToStore * 1000)) m"
        }
        return String(format: "%.1f km", distanceToStore)
    }
    
    // MARK: - Store Helpers
    /// Get all dark stores within range of a coordinate
    func storesInRange(of coordinate: CLLocationCoordinate2D) -> [DarkStore] {
        return darkStores.filter { $0.isServiceable(location: coordinate) }
    }
    
    /// Check if any store can service a location
    func canDeliver(to coordinate: CLLocationCoordinate2D) -> Bool {
        return darkStores.contains { $0.isServiceable(location: coordinate) }
    }
}
