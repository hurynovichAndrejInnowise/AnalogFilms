import SwiftUI
import Kingfisher

struct FilmRowView: View {
    let film: Film
    let onTap: () -> Void
    let onFavoriteToggle: ((Film) -> Void)?
    
    @State private var isPressed = false
    @State private var favoriteScale: CGFloat = 1.0
    @State private var showFavoriteEffect = false
    @State private var pulseEffect = false
    
    init(film: Film, onTap: @escaping () -> Void, onFavoriteToggle: ((Film) -> Void)? = nil) {
        self.film = film
        self.onTap = onTap
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
            filmImageView
                .frame(width: DesignTokens.FilmImage.rowWidth)
            
            filmContentView
                .frame(maxWidth: .infinity, alignment: .leading)
            
            favoriteButtonView
                .frame(width: 44)
        }
        .padding(DesignTokens.Spacing.lg)
        .modernCard(isPressed: isPressed)
        .overlay(
            // Favorite effect overlay
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    DesignTokens.Colors.favoriteRed.opacity(showFavoriteEffect ? 0.6 : 0),
                    lineWidth: 2
                )
                .scaleEffect(showFavoriteEffect ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: showFavoriteEffect)
        )
        .scaleEffect(pulseEffect ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: pulseEffect)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
        .onChange(of: film.isFavorite) { oldValue, newValue in
            if newValue != oldValue {
                triggerFavoriteAnimation(isFavorite: newValue)
            }
        }
    }
    
    // MARK: - Film Image
    
    private var filmImageView: some View {
        KFImage(URL(string: film.image ?? ""))
            .placeholder {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignTokens.Colors.tertiaryBackground,
                                    DesignTokens.Colors.secondaryBackground
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shimmer()
                    
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        Image(systemName: "photo.artframe")
                            .font(.title2)
                            .foregroundColor(DesignTokens.Colors.textTertiary)
                        
                        Text("Film")
                            .font(.caption2)
                            .foregroundColor(DesignTokens.Colors.textTertiary)
                    }
                }
            }
            .retry(maxCount: 3, interval: .seconds(1))
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fill)
        .frame(
            width: DesignTokens.FilmImage.rowWidth,
            height: DesignTokens.FilmImage.rowHeight
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .stroke(DesignTokens.Colors.primaryAccent.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Film Content
    
    private var filmContentView: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            // Brand and Favorite Pin
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(film.brand)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(DesignTokens.Colors.primaryAccent.opacity(0.1))
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if film.isFavorite {
                    HStack(spacing: 2) {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundColor(DesignTokens.Colors.secondaryAccent)
                        
                        Text("Pinned")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(DesignTokens.Colors.secondaryAccent)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xs)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(DesignTokens.Colors.secondaryAccent.opacity(0.1))
                    )
                    .transition(.scale.combined(with: .opacity))
                    .fixedSize(horizontal: true, vertical: false)
                }
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            
            // Film Model Name
            Text(film.model)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // ISO and Popular Badge
            HStack(spacing: DesignTokens.Spacing.sm) {
                Label {
                    Text(film.iso)
                        .font(.caption)
                        .fontWeight(.medium)
                } icon: {
                    Image(systemName: "camera.aperture")
                        .font(.caption)
                }
                .foregroundColor(DesignTokens.Colors.textSecondary)
                
                if film.isPopular {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("Popular")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(DesignTokens.Colors.popularYellow)
                    .padding(.horizontal, DesignTokens.Spacing.xs)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(DesignTokens.Colors.popularYellow.opacity(0.1))
                    )
                }
                
                Spacer()
            }
            
            // Film Type & Color Info
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                FlowLayout(spacing: DesignTokens.Spacing.xs) {
                    ForEach(film.type, id: \.self) { type in
                        Text(type)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(DesignTokens.Colors.textTertiary)
                            .padding(.horizontal, DesignTokens.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(DesignTokens.Colors.tertiaryBackground)
                            )
                    }
                    
                    FilmColorTypeView(
                        colorType: film.colorType,
                        size: .small,
                        style: .badgeCompact
                    )
                }
            }
            
            // Removed Text film color badge
        }
    }
    
    // MARK: - Favorite Button
    
    private var favoriteButtonView: some View {
        Button {
            // Trigger immediate visual feedback
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoriteScale = 1.4
                pulseEffect = true
            }
            
            // Reset scale and pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoriteScale = 1.0
                    pulseEffect = false
                }
            }
            
            // Call the toggle function
            onFavoriteToggle?(film)
            
        } label: {
            ZStack {
                // Background circle with animation
                Circle()
                    .fill(
                        film.isFavorite
                        ? DesignTokens.Colors.favoriteRed.opacity(0.15)
                        : DesignTokens.Colors.textTertiary.opacity(0.1)
                    )
                    .frame(width: 44, height: 44)
                    .scaleEffect(favoriteScale)
                
                // Heart icon with particles effect when favorited
                ZStack {
                    Image(systemName: film.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(
                            film.isFavorite
                            ? DesignTokens.Colors.favoriteRed
                            : DesignTokens.Colors.textSecondary
                        )
                        .scaleEffect(favoriteScale)
                    
                    // Particle effect for favorites
                    if film.isFavorite && showFavoriteEffect {
                        ForEach(0..<6, id: \.self) { index in
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundColor(DesignTokens.Colors.favoriteRed.opacity(0.7))
                                .offset(
                                    x: cos(Double(index) * .pi / 3) * 20,
                                    y: sin(Double(index) * .pi / 3) * 20
                                )
                                .scaleEffect(showFavoriteEffect ? 0.3 : 0)
                                .opacity(showFavoriteEffect ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                                    value: showFavoriteEffect
                                )
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Animation Helper
    
    private func triggerFavoriteAnimation(isFavorite: Bool) {
        if isFavorite {
            // Show favorite effect
            showFavoriteEffect = false
            withAnimation(.easeInOut(duration: 0.1)) {
                showFavoriteEffect = true
            }
            
            // Reset effect after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showFavoriteEffect = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        FilmRowView(
            film: Film(
                id: "1",
                brand: "Kodak",
                model: "Portra 400",
                slug: "kodak-portra-400",
                type: ["135", "120"],
                color: "Color negative",
                iso: "400",
                image: nil,
                yearStart: 1998,
                yearEnd: nil,
                country: "USA",
                description: "Professional color negative film",
                purchaseLinks: [],
                isFavorite: false,
                isPopular: true,
                isDead: false
            ),
            onTap: {},
            onFavoriteToggle: { _ in }
        )
        
        FilmRowView(
            film: Film(
                id: "2",
                brand: "Fujifilm",
                model: "Pro 400H",
                slug: "fujifilm-pro-400h",
                type: ["135", "120"],
                color: "Color negative",
                iso: "400",
                image: nil,
                yearStart: 2001,
                yearEnd: "2021",
                country: "Japan",
                description: "Professional color negative film",
                purchaseLinks: [],
                isFavorite: true,
                isPopular: false,
                isDead: true
            ),
            onTap: {},
            onFavoriteToggle: { _ in }
        )
    }
    .padding()
    .gradientBackground()
}
