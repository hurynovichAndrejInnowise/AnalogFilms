import SwiftUI
import Combine
import Kingfisher

struct FilmDetailView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: FilmDetailViewModel?
    @State private var scrollOffset: CGFloat = 0
    @State private var favoriteScale: CGFloat = 1.0
    @State private var imageScale: CGFloat = 1.0
    
    let coordinator: AppCoordinator
    let film: Film
    @EnvironmentObject private var containerWrapper: ContainerWrapper
    
    @State private var onFilmUpdated: ((Film) -> Void)?
    
    // MARK: - Initialization
    
    init(film: Film, coordinator: AppCoordinator) {
        self.film = film
        self.coordinator = coordinator
    }
    
    init(film: Film, coordinator: AppCoordinator, onFilmUpdated: ((Film) -> Void)? = nil) {
        self.film = film
        self.coordinator = coordinator
        self._onFilmUpdated = State(initialValue: onFilmUpdated)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Main Content
            Group {
                if let viewModel = viewModel {
                    modernFilmDetailContent(viewModel: viewModel)
                } else {
                    modernLoadingView
                }
            }
        }
        .onAppear {
            setupViewModel()
            withAnimation(.easeInOut(duration: 0.8)) {
                imageScale = 1.0
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.98, blue: 1.0),
                Color(red: 0.95, green: 0.96, blue: 0.98),
                Color(red: 0.92, green: 0.94, blue: 0.97)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Modern Loading View
    
    private var modernLoadingView: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            // Skeleton Image
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(DesignTokens.Colors.secondaryBackground)
                .frame(
                    width: DesignTokens.FilmImage.detailMaxWidth * 0.8,
                    height: DesignTokens.FilmImage.detailMaxHeight * 0.8
                )
                .shimmer()
            
            VStack(spacing: DesignTokens.Spacing.md) {
                // Skeleton Text Lines
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                        .fill(DesignTokens.Colors.secondaryBackground)
                        .frame(height: 20)
                        .shimmer()
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Setup
    
    private func setupViewModel() {
        if viewModel == nil, let filmService = containerWrapper.container.resolve(FilmServiceLogic.self) {
            viewModel = FilmDetailViewModel(film: film, filmService: filmService)
            
            viewModel?.setUpdateCallback { updatedFilm in
                onFilmUpdated?(updatedFilm)
            }
        }
    }
    
    // MARK: - Modern Film Detail Content
    
    private func modernFilmDetailContent(viewModel: FilmDetailViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Content Section
                VStack(spacing: DesignTokens.Spacing.xl) {
                    // Film Info Card
                    filmInfoCard(for: viewModel.film)
                    
                    // Specifications Card
                    specificationsCard(for: viewModel.film)
                    
                    // Description Card
                    if !viewModel.film.description.isEmpty {
                        descriptionCard(for: viewModel.film)
                    }
                    
                    // Purchase Links Card
                    if !viewModel.film.purchaseLinks.isEmpty {
                        purchaseLinksCard(for: viewModel.film)
                    }
                    
                    // Bottom Spacing
                    Spacer(minLength: DesignTokens.Spacing.xxxl)
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.top, DesignTokens.Spacing.lg)
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .navigationTitle(viewModel.film.model)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            modernToolbarContent(viewModel: viewModel)
        }
        .refreshable {
            await viewModel.refreshFilm()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.showError },
            set: { _ in viewModel.showError = false }
        )) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
    
    // MARK: - Film Info Card
    
    private func filmInfoCard(for film: Film) -> some View {
        ZStack {
            // Background with dynamic gradient based on film type
            backgroundForFilm(film)
            
            VStack(spacing: 0) {
                // Top section with image and floating elements
                topHeroSection(for: film)
                
                // Bottom section with film details
                bottomInfoSection(for: film)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl))
        .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 12)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
    
    private func backgroundForFilm(_ film: Film) -> some View {
        LinearGradient(
            colors: gradientColorsForFilm(film),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Subtle pattern overlay
            LinearGradient(
                colors: [
                    .white.opacity(0.1),
                    .clear,
                    .black.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func gradientColorsForFilm(_ film: Film) -> [Color] {
        switch film.colorType {
        case .blackAndWhite:
            return [
                Color(red: 0.15, green: 0.15, blue: 0.20),
                Color(red: 0.25, green: 0.25, blue: 0.30),
                Color(red: 0.35, green: 0.35, blue: 0.40)
            ]
        case .color:
            return [
                Color(red: 0.98, green: 0.85, blue: 0.70),
                Color(red: 0.95, green: 0.75, blue: 0.85),
                Color(red: 0.85, green: 0.90, blue: 0.98)
            ]
        case .other:
            return [
                Color(red: 0.92, green: 0.94, blue: 0.98),
                Color(red: 0.88, green: 0.92, blue: 0.96),
                Color(red: 0.85, green: 0.90, blue: 0.95)
            ]
        }
    }
    
    private func topHeroSection(for film: Film) -> some View {
        ZStack {
            KFImage(URL(string: film.image ?? ""))
                .placeholder {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shimmer()
                        
                        VStack(spacing: DesignTokens.Spacing.md) {
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 48, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Loading Film Image")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .retry(maxCount: 3, interval: .seconds(2))
                .fade(duration: 0.3)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(imageScale)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous))
            .overlay(
                // Dark overlay for better text readability
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .black.opacity(0.3),
                                .black.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            
            // Floating status indicators
            VStack {
                HStack {
                    // Brand badge in top-left
                    Text(film.brand)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Spacer()
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.lg)
                
                Spacer()
                
                // Bottom floating badges
                HStack {
                    if film.isPopular {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("Popular")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(DesignTokens.Colors.popularYellow.opacity(0.9))
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    
                    if film.isDead {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text("Discontinued")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(DesignTokens.Colors.secondaryAccent.opacity(0.9))
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    
                    if film.isFavorite {
                        HStack(spacing: 4) {
                            Image(systemName: "pin.fill")
                                .font(.caption)
                            Text("Pinned")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(DesignTokens.Colors.favoriteRed.opacity(0.9))
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
        }
    }
    
    // MARK: - Bottom Info Section
    
    private func bottomInfoSection(for film: Film) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            // Film model name with dramatic typography
            HStack {
                Text(film.model)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(film.colorType == .blackAndWhite ? .white : DesignTokens.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
        .padding(.vertical, DesignTokens.Spacing.lg)
    }
    
    // MARK: - Specifications Card
    
    private func specificationsCard(for film: Film) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
                
                Text("Specifications")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: DesignTokens.Spacing.md) {
                modernSpecRow(
                    icon: "camera.aperture",
                    title: "ISO Sensitivity",
                    value: film.iso,
                    accent: DesignTokens.Colors.primaryAccent
                )
                
                modernSpecRow(
                    icon: "film",
                    title: "Film Type",
                    value: film.type.joined(separator: ", "),
                    accent: DesignTokens.Colors.secondaryAccent
                )
                
                modernSpecRow(
                    icon: "globe",
                    title: "Country",
                    value: film.country,
                    accent: DesignTokens.Colors.primaryAccent
                )
                
                if film.hasValidYears {
                    modernSpecRow(
                        icon: "calendar",
                        title: "Production Years",
                        value: film.formattedYears,
                        accent: DesignTokens.Colors.textSecondary
                    )
                }
                
                modernColorTypeSpecRow(for: film)
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .modernCard()
    }
    
    private func modernColorTypeSpecRow(for film: Film) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignTokens.Colors.successGreen.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "paintpalette.fill")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Colors.successGreen)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Color Type")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                
                FilmColorTypeView(
                    colorType: film.colorType,
                    size: .medium,
                    style: .badgeFull
                )
            }
            
            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }
    
    // MARK: - Description Card
    
    private func descriptionCard(for film: Film) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            HStack {
                Image(systemName: "text.alignleft")
                    .font(.title3)
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
                
                Text("About This Film")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
            }
            
            Text(film.description)
                .font(.body)
                .lineSpacing(6)
                .foregroundColor(DesignTokens.Colors.textPrimary)
        }
        .padding(DesignTokens.Spacing.xl)
        .modernCard()
    }
    
    // MARK: - Purchase Links Card
    
    private func purchaseLinksCard(for film: Film) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.title3)
                    .foregroundColor(DesignTokens.Colors.successGreen)
                
                Text("Where to Buy")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: DesignTokens.Spacing.md) {
                ForEach(Array(film.purchaseLinks.enumerated()), id: \.offset) { index, link in
                    modernPurchaseLink(link: link, index: index)
                }
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .modernCard()
    }
    
    private func modernPurchaseLink(link: String, index: Int) -> some View {
        Link(destination: URL(string: link) ?? URL(string: "https://google.com")!) {
            HStack(spacing: DesignTokens.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignTokens.Colors.successGreen.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "cart")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignTokens.Colors.successGreen)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Purchase Link \(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                    
                    Text("Tap to open in browser")
                        .font(.caption)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Colors.successGreen)
            }
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(DesignTokens.Colors.successGreen.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                            .stroke(DesignTokens.Colors.successGreen.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Helper Views
    
    private func modernBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
    
    private func modernSpecRow(icon: String, title: String, value: String, accent: Color) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(accent)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }
    
    // MARK: - Modern Toolbar
    
    @ToolbarContentBuilder
    private func modernToolbarContent(viewModel: FilmDetailViewModel) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoriteScale = 1.3
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favoriteScale = 1.0
                    }
                }
                
                Task {
                    await viewModel.toggleFavorite()
                    if let onFilmUpdated = onFilmUpdated {
                        onFilmUpdated(viewModel.film)
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            viewModel.film.isFavorite
                            ? DesignTokens.Colors.favoriteRed.opacity(0.1)
                            : Color.clear
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: viewModel.film.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(
                            viewModel.film.isFavorite
                            ? DesignTokens.Colors.favoriteRed
                            : DesignTokens.Colors.textSecondary
                        )
                        .scaleEffect(favoriteScale)
                }
            }
        }
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        FilmDetailView(
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
                description: "Professional color negative film with excellent skin tones and fine grain. Perfect for portraits and wedding photography.",
                purchaseLinks: ["https://example.com/buy1", "https://example.com/buy2"],
                isFavorite: false,
                isPopular: true,
                isDead: false
            ),
            coordinator: AppCoordinator()
        )
    }
    .environmentObject(ContainerWrapper(container: ContainerFactory.createContainer()))
}
