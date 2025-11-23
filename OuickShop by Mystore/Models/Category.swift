import Foundation

struct Category: Identifiable {
    let id: String
    let name: String
    let imageURL: String
    let color: String // For UI styling
}

// Extensions for sample data
extension Category {
    static var sampleCategories: [Category] {
        [
            Category(id: "c0", name: "All", imageURL: "all", color: "gray"),
            Category(id: "c1", name: "Summer", imageURL: "summer", color: "primaryGreen"),
            Category(id: "c2", name: "Electronics", imageURL: "electronics", color: "blue"),
            Category(id: "c3", name: "Beauty", imageURL: "beauty", color: "purple"),
            Category(id: "c4", name: "Decor", imageURL: "decor", color: "orange"),
            Category(id: "c5", name: "Kids", imageURL: "kids", color: "pink")
        ]
    }
} 