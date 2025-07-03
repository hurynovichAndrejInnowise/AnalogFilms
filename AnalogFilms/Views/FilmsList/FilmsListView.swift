import SwiftUI
import Combine

struct FilmsListView: View {
    
    @State private var viewModel: FilmsListViewModel?
    @State private var coordinator: AppCoordinator
    @State private var scrollOffset: CGFloat = 0
    @EnvironmentObject private var containerWrapper: ContainerWrapper
    @EnvironmentObject private var appStateManager: AppStateManager
    
    init() {
        self._coordinator = State(initialValue: AppCoordinator())
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                // Background
                backgroundGradient
                
                // Main Content
                Group {
                    if let viewModel = viewModel {
                        filmsMainContent(viewModel: viewModel)
                    } else {
                        modernLoadingView
                    }
                }
                
                // Floating Elements
                if let viewModel = viewModel {
                    floatingElements(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            setupViewModel()
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
            // Animated Logo/Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent.opacity(0.3),
                                DesignTokens.Colors.secondaryAccent.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: scrollOffset
                    )
                
                Image(systemName: "camera.vintage")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
            }
            
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("Loading Films...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Text("Discovering analog treasures")
                    .font(.subheadline)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
            }
            
            // Modern Progress Indicator
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Colors.primaryAccent))
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            scrollOffset = 1.0
        }
    }
    
    // MARK: - Setup
    
    private func setupViewModel() {
        if viewModel == nil, let filmService = containerWrapper.container.resolve(FilmServiceLogic.self) {
            viewModel = FilmsListViewModel(filmService: filmService)
        }
    }
    
    // MARK: - Main Content
    
    private func filmsMainContent(viewModel: FilmsListViewModel) -> some View {
        Group {
            if viewModel.isLoading && viewModel.films.isEmpty {
                modernLoadingView
            } else if viewModel.isEmpty {
                modernEmptyStateView {
                    Task { await viewModel.refresh() }
                }
            } else {
                filmsScrollView(viewModel: viewModel)
            }
        }
        .navigationTitle("Analog Films")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            modernToolbarContent(viewModel: viewModel)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .searchable(
            text: Binding(
                get: { viewModel.filter.searchText },
                set: { viewModel.filter.searchText = $0 }
            ),
            prompt: "Search films..."
        )
        .onSubmit(of: .search) {
            Task { await viewModel.searchFilms() }
        }
        .onChange(of: viewModel.filter.searchText) { oldValue, newValue in
            if newValue != oldValue {
                Task {
                    // Simple debounce - wait 500ms before searching
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    // Only search if text hasn't changed again
                    if newValue == viewModel.filter.searchText {
                        await viewModel.searchFilms()
                    }
                }
            }
        }
        .onChange(of: viewModel.filter.searchText) { oldValue, newValue in
            if newValue.isEmpty && !oldValue.isEmpty {
                Task { await viewModel.searchFilms() }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showingFilterSheet },
            set: { viewModel.showingFilterSheet = $0 }
        )) {
            modernFilterSheet(viewModel: viewModel)
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.showError },
            set: { viewModel.showError = $0 }
        )) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .navigationDestination(for: AppRoute.self) { route in
            destinationView(for: route)
        }
    }
    
    // MARK: - Films Scroll View
    
    private func filmsScrollView(viewModel: FilmsListViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: DesignTokens.Spacing.md) {
                // Header Section
                headerSection(viewModel: viewModel)
                
                // Films List
                ForEach(Array(viewModel.films.enumerated()), id: \.element.id) { index, film in
                    filmRowWithAnimation(film: film, index: index, viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .leading))
                        ))
                }
                
                // Loading More Indicator
                if viewModel.isLoadingMore {
                    modernLoadingMoreView
                }
                
                // Total Count
                if viewModel.shouldShowTotalCount {
                    totalCountView(viewModel: viewModel)
                }
                
                // Bottom Padding
                Spacer(minLength: DesignTokens.Spacing.xxxl)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(viewModel: FilmsListViewModel) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            if !viewModel.favoriteFilms.isEmpty {
                HStack {
                    Label {
                        Text("\(viewModel.favoriteFilms.count) favorites")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "heart.fill")
                            .font(.subheadline)
                    }
                    .foregroundColor(DesignTokens.Colors.favoriteRed)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(DesignTokens.Colors.favoriteRed.opacity(0.1))
                    )
                    
                    Spacer()
                }
                .padding(.top, DesignTokens.Spacing.sm)
            }
        }
    }
    
    // MARK: - Film Row with Animation
    
    private func filmRowWithAnimation(film: Film, index: Int, viewModel: FilmsListViewModel) -> some View {
        FilmRowView(
            film: film,
            onTap: {
                coordinator.navigate(to: .filmDetail(film))
            },
            onFavoriteToggle: { film in
                Task {
                    await viewModel.toggleFavorite(for: film)
                }
            }
        )
        .onAppear {
            // Simplified pagination logic: trigger when near the end of the total list
            let totalFilms = viewModel.films.count
            let threshold = max(0, totalFilms - 5)
            
            // Debug info
            let isNearEnd = index >= threshold
            let canLoadMore = viewModel.hasMoreFilms && !viewModel.isLoadingMore && !viewModel.isLoading
            
            print("📍 Film at index \(index)/\(totalFilms), threshold: \(threshold)")
            print("🔍 isNearEnd: \(isNearEnd), canLoadMore: \(canLoadMore)")
            print("📊 hasMoreFilms: \(viewModel.hasMoreFilms), isLoadingMore: \(viewModel.isLoadingMore), isLoading: \(viewModel.isLoading)")
            
            if isNearEnd && canLoadMore {
                print("🚀 Triggering pagination at index \(index)")
                Task {
                    await viewModel.loadMoreFilms()
                }
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .top)),
            removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .leading))
        ))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.films.map { $0.id })
    }
    
    // MARK: - Modern Empty State
    
    private func modernEmptyStateView(retryAction: @escaping () -> Void) -> some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            // Animated Empty Icon
            ZStack {
                Circle()
                    .fill(DesignTokens.Colors.secondaryBackground)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(DesignTokens.Colors.textTertiary)
            }
            .scaleEffect(1.0)
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: scrollOffset
            )
            
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("No Films Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Text("Try adjusting your search or filters, or check your internet connection.")
                    .font(.subheadline)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.xl)
            }
            
            Button {
                retryAction()
            } label: {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, DesignTokens.Spacing.xl)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignTokens.Colors.primaryAccent,
                                    DesignTokens.Colors.primaryAccent.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            scrollOffset = 1.0
        }
    }
    
    // MARK: - Modern Loading More
    
    private var modernLoadingMoreView: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Colors.primaryAccent))
                .scaleEffect(0.8)
            
            Text("Loading more films...")
                .font(.subheadline)
                .foregroundColor(DesignTokens.Colors.textSecondary)
        }
        .padding(.vertical, DesignTokens.Spacing.lg)
    }
    
    // MARK: - Total Count View
    
    private func totalCountView(viewModel: FilmsListViewModel) -> some View {
        Text("Showing \(viewModel.totalFilmsShown) films")
            .font(.caption)
            .foregroundColor(DesignTokens.Colors.textTertiary)
            .padding(.vertical, DesignTokens.Spacing.lg)
    }
    
    // MARK: - Floating Elements
    
    private func floatingElements(viewModel: FilmsListViewModel) -> some View {
        VStack {
            // Offline Banner
            if viewModel.showOfflineBanner {
                modernOfflineBanner {
                    viewModel.dismissOfflineBanner()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.showOfflineBanner)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Modern Offline Banner
    
    private func modernOfflineBanner(dismissAction: @escaping () -> Void) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "wifi.slash")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("No Internet Connection")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Showing cached favorites only")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button {
                dismissAction()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(.white.opacity(0.2)))
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignTokens.Colors.secondaryAccent,
                            DesignTokens.Colors.secondaryAccent.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.top, DesignTokens.Spacing.sm)
    }
    
    // MARK: - Modern Toolbar
    
    @ToolbarContentBuilder
    private func modernToolbarContent(viewModel: FilmsListViewModel) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                coordinator.navigate(to: .userProfile)
            } label: {
                ZStack {
                    Circle()
                        .fill(DesignTokens.Colors.primaryAccent.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                        .foregroundColor(DesignTokens.Colors.primaryAccent)
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.showingFilterSheet = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            viewModel.filter.hasActiveFilters
                            ? DesignTokens.Colors.primaryAccent.opacity(0.1)
                            : Color.clear
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: viewModel.filter.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.title3)
                        .foregroundColor(
                            viewModel.filter.hasActiveFilters
                            ? DesignTokens.Colors.primaryAccent
                            : DesignTokens.Colors.textSecondary
                        )
                }
            }
        }
    }
    
    // MARK: - Modern Filter Sheet
    
    private func modernFilterSheet(viewModel: FilmsListViewModel) -> some View {
        FilterSheetView(
            filter: Binding(
                get: { viewModel.filter },
                set: { viewModel.filter = $0 }
            ),
            brands: viewModel.brands,
            clearAction: { 
                Task {
                    await viewModel.clearFilters()
                }
            },
            onSortChanged: {
                Task {
                    await viewModel.applySortChange()
                }
            },
            onBrandChanged: {
                Task {
                    await viewModel.applyBrandChange()
                }
            }
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Destination View
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .filmDetail(let film):
            FilmDetailView(
                film: film,
                coordinator: coordinator,
                onFilmUpdated: { updatedFilm in
                    // Update the film in the list
                    if let viewModel = viewModel {
                        Task {
                            await viewModel.updateFilm(updatedFilm)
                        }
                    }
                }
            )
        case .userProfile:
            UserProfileView {
                // Handle logout
                appStateManager.logout()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FilmsListView()
        .environmentObject(ContainerWrapper(container: ContainerFactory.createContainer()))
}