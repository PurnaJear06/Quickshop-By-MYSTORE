import Foundation
import CoreLocation

struct Address: Identifiable {
    let id: String
    let title: String // e.g., "Home", "Work"
    let fullAddress: String
    let landmark: String?
    let isDefault: Bool
    let latitude: Double
    let longitude: Double
    
    // Computed coordinate
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Computed property for short address display
    var shortAddress: String {
        let components = fullAddress.components(separatedBy: ",")
        if components.count >= 2 {
            return "\(components[0]), \(components[1])"
        }
        return fullAddress.count > 30 ? String(fullAddress.prefix(30)) + "..." : fullAddress
    }
    
    // Icon for address label (Home/Work/Other)
    var labelIcon: String {
        switch title.lowercased() {
        case "home":
            return "house.fill"
        case "work", "office":
            return "briefcase.fill"
        case "gym":
            return "dumbbell.fill"
        case "hotel":
            return "building.2.fill"
        default:
            return "mappin.circle.fill"
        }
    }
    
    // Color for address label
    var labelColor: String {
        switch title.lowercased() {
        case "home":
            return "primaryGreen"
        case "work", "office":
            return "primaryYellow"
        default:
            return "gray"
        }
    }
    
    // Init without coordinates (for backward compatibility)
    init(id: String, title: String, fullAddress: String, landmark: String?, isDefault: Bool, latitude: Double = 0.0, longitude: Double = 0.0) {
        self.id = id
        self.title = title
        self.fullAddress = fullAddress
        self.landmark = landmark
        self.isDefault = isDefault
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct User: Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let addresses: [Address]
    let profileImageURL: String?
    
    // Computed property for full name
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Legacy name property for backward compatibility
    var name: String {
        return fullName
    }
}

// Extensions for sample data
extension Address {
    static var sampleAddresses: [Address] {
        [
            Address(
                id: "a1",
                title: "Home",
                fullAddress: "Koramangala 4th Block, Bengaluru",
                landmark: "Near Forum Mall",
                isDefault: true,
                latitude: 12.9352,
                longitude: 77.6245
            ),
            Address(
                id: "a2",
                title: "Work",
                fullAddress: "HSR Layout Sector 2, Bengaluru",
                landmark: "Opposite Starbucks",
                isDefault: false,
                latitude: 12.9121,
                longitude: 77.6446
            )
        ]
    }
}

extension User {
    static var sampleUser: User {
        User(
            id: "user1",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "+91 9876543210",
            addresses: Address.sampleAddresses,
            profileImageURL: nil
        )
    }
} 