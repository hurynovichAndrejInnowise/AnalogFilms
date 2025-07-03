import SwiftUI

struct FilmColorTypeView: View {
    let colorType: FilmColorType
    let size: Size
    let style: Style
    
    enum Size {
        case small   // для ячеек
        case medium  // для деталей
        case large   // для больших карточек
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 12
            }
        }
        
        var circleSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 32
            case .large: return 40
            }
        }
        
        var textFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            case .large: return 12
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 4
            case .large: return 6
            }
        }
    }
    
    enum Style {
        case iconOnly    // только иконка в кружке
        case badgeCompact // компактный бейдж
        case badgeFull   // полный бейдж с текстом
    }
    
    var body: some View {
        switch style {
        case .iconOnly:
            iconOnlyView
        case .badgeCompact:
            badgeCompactView
        case .badgeFull:
            badgeFullView
        }
    }
    
    // MARK: - Icon Only
    
    private var iconOnlyView: some View {
        ZStack {
            if let gradient = colorType.circleGradient {
                Circle()
                    .fill(gradient)
                    .frame(width: size.circleSize, height: size.circleSize)
            } else {
                Circle()
                    .fill(colorType.backgroundColor)
                    .frame(width: size.circleSize, height: size.circleSize)
            }
            
            Image(systemName: colorType.icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(colorType.foregroundColor)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
    }
    
    // MARK: - Badge Compact
    
    private var badgeCompactView: some View {
        HStack(spacing: 4) {
            ZStack {
                if let gradient = colorType.circleGradient {
                    Circle()
                        .fill(gradient)
                        .frame(width: size.circleSize * 0.7, height: size.circleSize * 0.7)
                } else {
                    Circle()
                        .fill(colorType.backgroundColor)
                        .frame(width: size.circleSize * 0.7, height: size.circleSize * 0.7)
                }
                
                Image(systemName: colorType.icon)
                    .font(.system(size: size.iconSize * 0.8, weight: .medium))
                    .foregroundColor(colorType.foregroundColor)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
            
            Text(colorType == .blackAndWhite ? "B&W" : (colorType == .color ? "Color" : "Other"))
                .font(size.textFont)
                .fontWeight(.medium)
                .foregroundColor(DesignTokens.Colors.textSecondary)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(
            Capsule()
                .fill(DesignTokens.Colors.tertiaryBackground)
        )
    }
    
    // MARK: - Badge Full
    
    private var badgeFullView: some View {
        HStack(spacing: 6) {
            iconOnlyView
            
            Text(colorType.displayName)
                .font(size.textFont)
                .fontWeight(.semibold)
                .foregroundColor(colorType.foregroundColor)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(
            Capsule()
                .fill(
                    colorType.backgroundGradient != nil 
                        ? AnyShapeStyle(colorType.backgroundGradient!)
                        : AnyShapeStyle(colorType.backgroundColor)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 15) {
            FilmColorTypeView(colorType: .blackAndWhite, size: .small, style: .iconOnly)
            FilmColorTypeView(colorType: .color, size: .small, style: .iconOnly)
            FilmColorTypeView(colorType: .other, size: .small, style: .iconOnly)
        }
        
        HStack(spacing: 15) {
            FilmColorTypeView(colorType: .blackAndWhite, size: .medium, style: .badgeCompact)
            FilmColorTypeView(colorType: .color, size: .medium, style: .badgeCompact)
            FilmColorTypeView(colorType: .other, size: .medium, style: .badgeCompact)
        }
        
        VStack(spacing: 10) {
            FilmColorTypeView(colorType: .blackAndWhite, size: .large, style: .badgeFull)
            FilmColorTypeView(colorType: .color, size: .large, style: .badgeFull)
            FilmColorTypeView(colorType: .other, size: .large, style: .badgeFull)
        }
    }
    .padding()
}