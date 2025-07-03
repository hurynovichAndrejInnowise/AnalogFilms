import Foundation
import SwiftUI

enum FilmColorType: String, CaseIterable, Codable {
    case blackAndWhite = "Black and white"
    case color = "Color negative"
    case other = "Other"
    
    init(from colorString: String) {
        let lowercased = colorString.lowercased()
        
        if lowercased.contains("black") && lowercased.contains("white") ||
           lowercased.contains("b&w") ||
           lowercased.contains("monochrome") ||
           lowercased == "bw" {
            self = .blackAndWhite
        } else if lowercased.contains("color") && lowercased.contains("negative") ||
                  lowercased.contains("colour") && lowercased.contains("negative") ||
                  lowercased == "color negative" ||
                  lowercased == "colour negative" {
            self = .color
        } else {
            self = .other
        }
    }
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .blackAndWhite:
            return "circle.fill"
        case .color:
            return "paintpalette.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .blackAndWhite:
            return .black
        case .color:
            return .clear // Will use gradient
        case .other:
            return Color(red: 0.5, green: 0.5, blue: 0.5)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .blackAndWhite:
            return .white
        case .color:
            return .white
        case .other:
            return .white
        }
    }
    
    var backgroundGradient: LinearGradient? {
        switch self {
        case .color:
            return LinearGradient(
                colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            return nil
        }
    }
    
    var circleGradient: AngularGradient? {
        switch self {
        case .color:
            return AngularGradient(
                colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .red],
                center: .center
            )
        default:
            return nil
        }
    }
}

struct Film: Codable, Identifiable, Hashable {
    
    // MARK: - Properties
    
    let id: String
    
    let brand: String
    let model: String
    let slug: String
    
    let type: [String]
    let color: String
    let iso: String
    
    let image: String?
    
    let yearStart: Int?
    let yearEnd: String?
    
    let country: String
    let description: String
    
    let purchaseLinks: [String]
    
    let isFavorite: Bool
    let isPopular: Bool
    let isDead: Bool
    
    // MARK: - Computed Properties
    
    var formattedYears: String {
        guard let yearStart = yearStart, yearStart > 0 else {
            return ""
        }
        
        if let yearEnd = yearEnd, !yearEnd.isEmpty {
            return "\(yearStart) - \(yearEnd)"
        } else {
            return "\(yearStart) - Present"
        }
    }
    
    var hasValidYears: Bool {
        return yearStart != nil && (yearStart ?? 0) > 0
    }

    var filmTypes: String {
        type.joined(separator: ", ")
    }
    
    var colorType: FilmColorType {
        return FilmColorType.init(from: color)
    }
}

// MARK: - Coding Keys

extension Film {
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        
        case brand = "brand"
        case model = "model"
        case slug = "slug"
        
        case type = "type"
        case color = "color"
        case iso = "isoMin"
        
        case image = "image"
        
        case yearStart = "yearStart"
        case yearEnd = "yearEnd"
        
        case country = "country"
        case description = "description"
        
        case purchaseLinks = "purchaseLinks"
        
        case isFavorite = "isFavorite"
        case isPopular = "isPopular"
        case isDead = "isDead"
    }
}
