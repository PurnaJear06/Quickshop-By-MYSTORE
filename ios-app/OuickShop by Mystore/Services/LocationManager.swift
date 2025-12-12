import Foundation
import CoreLocation
import Combine

/// Manages device location services
class LocationManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var locationError: String?
    @Published var lastKnownAddress: String = ""
    
    // MARK: - Private Properties
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // MARK: - Singleton
    static let shared = LocationManager()
    
    // MARK: - Init
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }
    
    // MARK: - Permission
    /// Request location permission
    func requestPermission() {
        print("📍 Requesting location permission...")
        manager.requestWhenInUseAuthorization()
    }
    
    /// Check if location services are enabled
    var isLocationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }
    
    /// Check if permission is granted
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    // MARK: - Location Updates
    /// Get current location once
    func getCurrentLocation() {
        guard isAuthorized else {
            locationError = "Location permission not granted"
            print("❌ Location not authorized")
            return
        }
        
        isLoading = true
        locationError = nil
        manager.requestLocation()
        print("📍 Requesting current location...")
    }
    
    /// Request current location (alias for UI convenience)
    func requestCurrentLocation() {
        getCurrentLocation()
    }
    
    /// Start continuous location updates
    func startUpdatingLocation() {
        guard isAuthorized else {
            requestPermission()
            return
        }
        manager.startUpdatingLocation()
    }
    
    /// Stop location updates
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Geocoding
    /// Reverse geocode a coordinate to address
    func reverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Geocoding error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    completion(nil)
                    return
                }
                
                // Build address string
                var addressParts: [String] = []
                
                if let subLocality = placemark.subLocality {
                    addressParts.append(subLocality)
                }
                if let locality = placemark.locality {
                    addressParts.append(locality)
                }
                if let administrativeArea = placemark.administrativeArea {
                    addressParts.append(administrativeArea)
                }
                
                let address = addressParts.joined(separator: ", ")
                self.lastKnownAddress = address
                completion(address)
            }
        }
    }
    
    /// Forward geocode an address to coordinate
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Forward geocoding error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    completion(nil)
                    return
                }
                
                completion(location.coordinate)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            print("📍 Authorization status changed: \(self.authorizationStatus.rawValue)")
            
            if self.isAuthorized {
                self.getCurrentLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.location = locations.last
            
            if let location = locations.last {
                print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                // Reverse geocode to get address
                self.reverseGeocode(coordinate: location.coordinate) { address in
                    if let address = address {
                        print("📍 Address: \(address)")
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.locationError = error.localizedDescription
            print("❌ Location error: \(error.localizedDescription)")
        }
    }
}
