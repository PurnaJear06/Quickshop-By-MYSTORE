import Foundation
import SwiftUI

// Helper to map category names to SF Symbols icons
struct CategoryIconMap {
    static func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "fruits":
            return "leaf.fill"
        case "vegetables":
            return "leaf.fill"
        case "dairy":
            return "cup.and.saucer.fill"
        case "bakery":
            return "birthday.cake.fill"
        case "meat":
            return "fork.knife"
        case "beverages":
            return "mug.fill"
        case "snacks":
            return "popcorn.fill"
        case "household":
            return "house.fill"
        case "summer":
            return "sun.max.fill"
        case "all":
            return "square.grid.2x2.fill"
        case "electronics":
            return "desktopcomputer"
        case "beauty":
            return "sparkles"
        case "decor":
            return "house.fill"
        case "kids":
            return "figure.child"
        default:
            return "square.grid.2x2.fill"
        }
    }
    
    static func colorName(for category: String) -> Color {
        switch category.lowercased() {
        case "fruits":
            return Color.blue
        case "vegetables":
            return Color.green
        case "dairy":
            return Color.blue
        case "bakery":
            return Color.orange
        case "meat":
            return Color.red
        case "beverages":
            return Color.cyan
        case "snacks":
            return Color.yellow
        case "household":
            return Color.purple
        case "summer":
            return Color("primaryGreen")
        case "electronics":
            return Color.blue
        case "beauty":
            return Color.purple
        case "decor":
            return Color.orange
        case "kids":
            return Color.pink
        default:
            return Color.gray
        }
    }
} 