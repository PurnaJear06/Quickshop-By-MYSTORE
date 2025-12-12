import Foundation

struct Address: Identifiable {
    let id: String
    let title: String // e.g., "Home", "Work"
    let fullAddress: String
    let landmark: String?
    let isDefault: Bool
    
    // Computed property for short address display
    var shortAddress: String {
        let components = fullAddress.components(separatedBy: ",")
        if components.count >= 2 {
            return "\(components[0]), \(components[1])"
        }
        return fullAddress.count > 30 ? String(fullAddress.prefix(30)) + "..." : fullAddress
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
            Address(id: "a1", title: "Home", fullAddress: "123 Main St, Apartment 4B, Mumbai", landmark: "Near Central Park", isDefault: true),
            Address(id: "a2", title: "Work", fullAddress: "456 Tech Park, Sector 5, Bangalore", landmark: "Opposite Coffee Shop", isDefault: false)
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