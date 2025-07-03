import Foundation
import Combine
import SwiftUI

@Observable
final class FilmsListViewModel {
    var favoriteFilms: [Film] = []
    var regularFilms: [Film] = []
    
    var brands: [String] = []
    var isLoading = false
    var isLoadingMore = false
    var isRefreshing = false
    var errorMessage: String?
    var showError = false
    var hasMoreFilms = true
    var totalFilmsShown = 0
    var isConnected = true
    var showOfflineBanner = false
    
    // MARK: - Filter State
    
    var filter = FilmFilter()
    var showingFilterSheet = false
    
    // MARK: - Private Properties
    
    private let filmService: FilmServiceLogic
    private let itemsPerPage = 25
    var currentOffset = 0
    private var cancellables = Set<AnyCancellable>()
    
    private var refreshTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    var films: [Film] {
        favoriteFilms + regularFilms
    }
    
    var isEmpty: Bool {
        films.isEmpty && !isLoading
    }
    
    var shouldShowTotalCount: Bool {
        !hasMoreFilms && !films.isEmpty
    }
    
    // MARK: - Initialization
    
    init(filmService: FilmServiceLogic) {
        self.filmService = filmService
        setupNetworkMonitoring()
        Task {
            await loadInitialData()
        }
    }
}

// MARK: - Public Methods

extension FilmsListViewModel {
    
    @MainActor
    func loadInitialData() async {
        await loadBrands()
        await loadFilms(refresh: false)
    }
    
    @MainActor
    func refresh() async {
        refreshTask?.cancel()
        
        guard !isRefreshing else { return }
        
        refreshTask = Task.detached { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.isRefreshing = true
                self.currentOffset = 0
                self.hasMoreFilms = true
                self.errorMessage = nil
                self.showError = false
            }
            
            do {
                // Load data sequentially to minimize state changes
                async let brandsTask = self.filmService.fetchBrands(forceRefresh: true)
                async let filmsTask = self.filmService.fetchFilms(
                    brand: await MainActor.run { self.filter.selectedBrand },
                    sortOption: await MainActor.run { self.filter.sortOption },
                    searchText: await MainActor.run {
                        let text = self.filter.searchText
                        return text.isEmpty ? nil : text
                    },
                    limit: self.itemsPerPage,
                    offset: 0,
                    forceRefresh: true
                )
                
                let (brands, response) = try await (brandsTask, filmsTask)
                
                // Update state in one batch to minimize re-renders
                await MainActor.run {
                    self.brands = brands
                    
                    let newFavorites = response.films.filter { $0.isFavorite }
                    let newRegular = response.films.filter { !$0.isFavorite }
                    
                    self.favoriteFilms = self.sortFilms(newFavorites, by: self.filter.sortOption)
                    self.regularFilms = newRegular  // Keep API order
                    
                    self.hasMoreFilms = response.films.count >= self.itemsPerPage
                    self.totalFilmsShown = self.films.count
                    self.isRefreshing = false
                }
                
                print(" refresh() completed")
                
            } catch {
                await MainActor.run {
                    self.isRefreshing = false
                    if !Task.isCancelled && (error as NSError).code != NSURLErrorCancelled {
                        self.showErrorMessage("Failed to refresh: \(error.localizedDescription)")
                    }
                }
                print(" refresh() failed: \(error)")
            }
        }
        
        await refreshTask?.value
    }
    
    func loadBrands(forceRefresh: Bool = false) async {
        do {
            let fetchedBrands = try await filmService.fetchBrands(forceRefresh: forceRefresh)
            await MainActor.run {
                self.brands = fetchedBrands
            }
        } catch {
            await MainActor.run {
                self.showErrorMessage("Failed to load brands: \(error.localizedDescription)")
            }
        }
    }
    
    func loadFilms(refresh: Bool, loadMore: Bool = false) async {
        if !loadMore {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
                showError = false
            }
        }
        
        do {
            print(" Loading films with offset: \(currentOffset), search: '\(filter.searchText)', loadMore: \(loadMore)")
            
            let response = try await filmService.fetchFilms(
                brand: await MainActor.run { self.filter.selectedBrand },
                sortOption: await MainActor.run { self.filter.sortOption },
                searchText: await MainActor.run {
                    let text = self.filter.searchText
                    return text.isEmpty ? nil : text
                },
                limit: self.itemsPerPage,
                offset: self.currentOffset,
                forceRefresh: refresh
            )
            
            print(" Received \(response.films.count) films from API")
            
            await MainActor.run {
                let newFavorites = response.films.filter { $0.isFavorite }
                let newRegular = response.films.filter { !$0.isFavorite }
                
                print(" New favorites: \(newFavorites.count), new regular: \(newRegular.count)")
                
                if loadMore {
                    regularFilms.append(contentsOf: newRegular)
                    print(" Appended \(newRegular.count) regular films. Total regular: \(self.regularFilms.count)")
                } else {
                    favoriteFilms = sortFilms(newFavorites, by: filter.sortOption)
                    regularFilms = newRegular
                    print(" Reset arrays. Favorites: \(self.favoriteFilms.count), Regular: \(self.regularFilms.count)")
                }
                
                self.hasMoreFilms = response.films.count >= self.itemsPerPage
                
                self.totalFilmsShown = self.films.count
                self.isLoading = false
                
                print(" currentOffset: \(self.currentOffset), hasMoreFilms: \(self.hasMoreFilms), total films: \(self.films.count)")
            }
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                if (error as NSError).code != NSURLErrorCancelled {
                    self.showErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    @MainActor
    func loadMoreFilms() async {
        guard !isLoadingMore && hasMoreFilms && !isLoading else {
            print(" LoadMoreFilms blocked - isLoadingMore: \(isLoadingMore), hasMoreFilms: \(hasMoreFilms), isLoading: \(isLoading)")
            return
        }
        
        loadMoreTask?.cancel()
        
        loadMoreTask = Task.detached { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.isLoadingMore = true
                self.currentOffset += self.itemsPerPage
            }
            
            do {
                let response = try await self.filmService.fetchFilms(
                    brand: await MainActor.run { self.filter.selectedBrand },
                    sortOption: await MainActor.run { self.filter.sortOption },
                    searchText: await MainActor.run { self.filter.searchText.isEmpty ? nil : self.filter.searchText },
                    limit: self.itemsPerPage,
                    offset: await MainActor.run { self.currentOffset },
                    forceRefresh: false
                )
                
                await MainActor.run {
                    let newRegular = response.films.filter { !$0.isFavorite }
                    self.regularFilms.append(contentsOf: newRegular)
                    
                    self.hasMoreFilms = response.films.count >= self.itemsPerPage
                    self.totalFilmsShown = self.films.count
                    self.isLoadingMore = false
                }
                
                print(" LoadMoreFilms completed - added \(response.films.count) films")
                
            } catch {
                await MainActor.run {
                    self.currentOffset -= self.itemsPerPage // Rollback offset
                    self.isLoadingMore = false
                    if !Task.isCancelled && (error as NSError).code != NSURLErrorCancelled {
                        self.showErrorMessage("Failed to load more: \(error.localizedDescription)")
                    }
                }
                print(" LoadMoreFilms failed: \(error)")
            }
        }
        
        await loadMoreTask?.value
    }
    
    @MainActor
    func searchFilms() async {
        currentOffset = 0
        hasMoreFilms = true
        favoriteFilms.removeAll()
        regularFilms.removeAll()
        await loadFilms(refresh: false)
    }
    
    @MainActor
    func applyFilters() async {
        print("🔄 applyFilters called - sortOption: \(filter.sortOption.apiValue)")
        
        // Clear current data and refresh from API with new parameters
        currentOffset = 0
        hasMoreFilms = true
        favoriteFilms.removeAll()
        regularFilms.removeAll()
        
        // Use refresh to get data with new sort/filter parameters from API
        await refresh()
        
        print("✅ applyFilters completed")
    }
    
    @MainActor
    func clearFilters() async {
        filter = FilmFilter()
        await applyFilters()
    }
    
    @MainActor
    func applySortChange() async {
        print("🔄 applySortChange called - sortOption: \(filter.sortOption.apiValue)")
        
        // Don't close sheet, just refresh data with new sort
        currentOffset = 0
        hasMoreFilms = true
        
        // Keep existing favorites but resort them
        let existingFavorites = favoriteFilms
        favoriteFilms = sortFilms(existingFavorites, by: filter.sortOption)
        
        // Clear regular films and reload from API with new sort
        regularFilms.removeAll()
        
        // Refresh to get properly sorted data from API
        await loadFilms(refresh: true)
        
        print("✅ applySortChange completed - favorites resorted, regular films reloaded")
    }
    
    @MainActor
    func applyBrandChange() async {
        print("🔄 applyBrandChange called - brand: \(filter.selectedBrand ?? "All")")
        
        // Don't close sheet, just refresh data with new brand filter
        currentOffset = 0
        hasMoreFilms = true
        favoriteFilms.removeAll()
        regularFilms.removeAll()
        
        // Refresh to get properly filtered data from API
        await loadFilms(refresh: true)
        
        print("✅ applyBrandChange completed - data reloaded with new brand filter")
    }
    
    @MainActor
    func toggleFavorite(for film: Film) async {
        do {
            let updatedFilm = try await filmService.toggleFavorite(for: film)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                if let favoriteIndex = favoriteFilms.firstIndex(where: { $0.id == film.id }) {
                    if updatedFilm.isFavorite {
                        favoriteFilms[favoriteIndex] = updatedFilm
                    } else {
                        favoriteFilms.remove(at: favoriteIndex)
                        
                        let sortedRegular = sortFilms(regularFilms + [updatedFilm], by: filter.sortOption)
                        regularFilms = sortedRegular
                    }
                } else if let regularIndex = regularFilms.firstIndex(where: { $0.id == film.id }) {
                    if updatedFilm.isFavorite {
                        regularFilms.remove(at: regularIndex)
                        
                        let sortedFavorites = sortFilms(favoriteFilms + [updatedFilm], by: filter.sortOption)
                        favoriteFilms = sortedFavorites
                    } else {
                        regularFilms[regularIndex] = updatedFilm
                    }
                }
                
                totalFilmsShown = films.count
            }
            
        } catch {
            await MainActor.run {
                self.showErrorMessage("Failed to update favorite: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func updateFilm(_ updatedFilm: Film) async {
        print("🔄 updateFilm called for '\(updatedFilm.model)', isFavorite: \(updatedFilm.isFavorite)")
        
        // Find the film in both lists
        let favoriteIndex = favoriteFilms.firstIndex(where: { $0.id == updatedFilm.id })
        let regularIndex = regularFilms.firstIndex(where: { $0.id == updatedFilm.id })
        
        print("📍 Film found - favoriteIndex: \(favoriteIndex?.description ?? "nil"), regularIndex: \(regularIndex?.description ?? "nil")")
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if updatedFilm.isFavorite {
                // Film should be in favorites
                if let regularIndex = regularIndex {
                    // Remove from regular
                    regularFilms.remove(at: regularIndex)
                    print("🔄 Removed from regular at index \(regularIndex)")
                }
                
                // Update or add to favorites
                if let favoriteIndex = favoriteIndex {
                    favoriteFilms[favoriteIndex] = updatedFilm
                    print("🔄 Updated in favorites at index \(favoriteIndex)")
                } else {
                    favoriteFilms.append(updatedFilm)
                    print("🔄 Added to favorites")
                }
                
                // Sort favorites locally (only favorites are sorted in app)
                favoriteFilms = sortFilms(favoriteFilms, by: filter.sortOption)
                print("✅ Resorted favorites locally - count: \(favoriteFilms.count)")
                
            } else {
                // Film should NOT be in favorites anymore
                if let favoriteIndex = favoriteIndex {
                    // Remove from favorites
                    favoriteFilms.remove(at: favoriteIndex)
                    print("🔄 Removed from favorites at index \(favoriteIndex)")
                }
                
                print("ℹ️ Film removed from favorites. Refreshing to get proper position from API.")
                
                // Update in regular films if it's already there
                if let regularIndex = regularIndex {
                    regularFilms[regularIndex] = updatedFilm
                    print("🔄 Updated existing film in regular at index \(regularIndex)")
                }
            }
            
            totalFilmsShown = films.count
        }
        
        print("📊 Final state - Favorites: \(favoriteFilms.count), Regular: \(regularFilms.count), Total: \(films.count)")
        
        if !updatedFilm.isFavorite {
            await refresh()
        }
    }
    
    func dismissOfflineBanner() {
        showOfflineBanner = false
    }
    
    @MainActor
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Private Methods

private extension FilmsListViewModel {
    
    func setupNetworkMonitoring() {
        filmService.networkStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isConnected = status == .connected
                self?.showOfflineBanner = status == .disconnected && !(self?.films.isEmpty ?? true)
            }
            .store(in: &cancellables)
    }
    
    func sortFilms(_ films: [Film], by sortOption: FilmSortOption) -> [Film] {
        let ascending = sortOption.order == .forward
        
        switch sortOption.field {
        case .name:
            return films.sorted { ascending ? $0.model < $1.model : $0.model > $1.model }
        case .popularity:
            return films.sorted { ascending ? !$0.isPopular && $1.isPopular : $0.isPopular && !$1.isPopular }
        case .iso:
            return films.sorted {
                let iso1 = Int($0.iso) ?? 0
                let iso2 = Int($1.iso) ?? 0
                return ascending ? iso1 < iso2 : iso1 > iso2
            }
        case .freshness:
            return films.sorted { ascending ? $0.id < $1.id : $0.id > $1.id }
        }
    }
}
