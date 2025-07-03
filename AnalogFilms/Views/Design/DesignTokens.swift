import SwiftUI

// MARK: - Design Tokens

enum DesignTokens {
    
    // MARK: - Colors
    enum Colors {
        static let primaryAccent = Color(red: 0.2, green: 0.4, blue: 0.9)
        static let secondaryAccent = Color(red: 0.9, green: 0.3, blue: 0.4)
        static let favoriteRed = Color(red: 0.95, green: 0.3, blue: 0.3)
        static let popularYellow = Color(red: 1.0, green: 0.8, blue: 0.0)
        static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
        
        static let cardBackground = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(.tertiaryLabel)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
    
    // MARK: - Film Image Dimensions
    enum FilmImage {
        // Standard film box ratio 3:2 (240:160)
        static let aspectRatio: CGFloat = 3.0 / 2.0
        
        // Row view dimensions
        static let rowWidth: CGFloat = 90
        static let rowHeight: CGFloat = 60
        
        // Detail view dimensions
        static let detailMaxHeight: CGFloat = 320
        static let detailMaxWidth: CGFloat = 480
    }
}