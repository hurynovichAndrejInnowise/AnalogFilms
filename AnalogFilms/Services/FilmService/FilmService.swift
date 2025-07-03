import Foundation
import Combine

final class FilmService: FilmServiceLogic {
    
    // MARK: - Properties
    
    private let networkService: NetworkServiceLogic
    private let dataService: DataServiceLogic
    
    // MARK: - Computed Properties
    
    var isConnected: Bool {
        networkService.isConnected
    }
    
    var networkStatusPublisher: AnyPublisher<NetworkStatus, Never> {
        networkService.networkStatusPublisher
    }
    
    // MARK: - Initialization
    
    init(
        networkService: NetworkServiceLogic,
        dataService: DataServiceLogic
    ) {
        self.networkService = networkService
        self.dataService = dataService
    }
}

// MARK: - Film Methods

extension FilmService {
    
    func fetchFilms(
        brand: String?,
        sortOption: FilmSortOption,
        searchText: String?,
        limit: Int,
        offset: Int,
        forceRefresh: Bool = false
    ) async throws -> FilmsDTO {
        
        print("🔄 FilmService.fetchFilms called with offset: \(offset), search: '\(searchText ?? "none")', forceRefresh: \(forceRefresh)")
        
        // Get favorite films from local storage
        let favoriteFilms = try await dataService.getFavoriteFilms()
        let filteredFavorites = filterFavoritesByBrandAndSearch(favoriteFilms, brand: brand, searchText: searchText)
        
        print("❤️ Found \(favoriteFilms.count) total favorites, \(filteredFavorites.count) filtered favorites")
        print("🌐 Network connected: \(networkService.isConnected)")
        print("🔧 Force refresh mode: \(forceRefresh)")
        
        if networkService.isConnected {
            // Always try to fetch from network when online
            do {
                print("📡 Attempting network fetch...")
                let response = try await networkService.fetchFilms(
                    brand: brand,
                    sortOption: sortOption,
                    searchText: searchText,
                    limit: limit,
                    offset: offset
                )
                
                print("✅ Network fetch successful: \(response.films.count) films, total: \(response.total)")
                
                var networkFilms = response.films
                
                // Mark network films that are favorites
                networkFilms = networkFilms.map { film in
                    let isFav = filteredFavorites.contains { $0.id == film.id }
                    return Film(
                        id: film.id,
                        brand: film.brand,
                        model: film.model,
                        slug: film.slug,
                        type: film.type,
                        color: film.color,
                        iso: film.iso,
                        image: film.image,
                        yearStart: film.yearStart,
                        yearEnd: film.yearEnd,
                        country: film.country,
                        description: film.description,
                        purchaseLinks: film.purchaseLinks,
                        isFavorite: isFav,
                        isPopular: film.isPopular,
                        isDead: film.isDead
                    )
                }
                
                // If this is the first page (offset == 0), prepend favorites that are NOT in network response
                if offset == 0 {
                    print("📄 First page - combining with favorites")
                    let networkIds = Set(networkFilms.map { $0.id })
                    let favoritesNotInNetwork = filteredFavorites.filter { !networkIds.contains($0.id) }
                    
                    print("🔗 Favorites not in network: \(favoritesNotInNetwork.count)")
                    
                    // Sort favorites and network films separately
                    let sortedFavorites = sortFilms(favoritesNotInNetwork, by: sortOption)
                    let sortedNetworkFilms = sortFilms(networkFilms, by: sortOption)
                    
                    // Combine: favorites first, then network films
                    let allFilms = sortedFavorites + sortedNetworkFilms
                    print("🎯 Returning \(allFilms.count) total films (favorites + network)")
                    return FilmsDTO(films: allFilms, total: response.total + favoritesNotInNetwork.count)
                } else {
                    // For subsequent pages, only return network films (with favorite status marked)
                    print("📄 Subsequent page - network films only")
                    let sortedNetworkFilms = sortFilms(networkFilms, by: sortOption)
                    print("🎯 Returning \(sortedNetworkFilms.count) network films")
                    return FilmsDTO(films: sortedNetworkFilms, total: response.total)
                }
                
            } catch {
                let nsError = error as NSError
                if nsError.code == NSURLErrorCancelled {
                    print("🚫 Network request cancelled, falling back to favorites")
                    // Don't throw cancelled errors, fall through to show favorites
                } else {
                    print("❌ Network fetch failed: \(error)")
                    throw error
                }
            }
        }
        
        print("📱 Offline mode or showing favorites due to cancelled request")
        
        // If offline or cancelled, show only favorites (only on first page)
        if offset == 0 {
            let sortedFavorites = self.sortFilms(filteredFavorites, by: sortOption)
            print("🎯 Returning \(sortedFavorites.count) offline/cached favorites")
            return FilmsDTO(films: sortedFavorites, total: sortedFavorites.count)
        } else {
            // No more data available offline for subsequent pages
            print("🎯 Returning empty list for offline pagination")
            return FilmsDTO(films: [], total: 0)
        }
    }
    
    func getFilm(by id: String) async throws -> Film? {
        // First check if it's a favorite
        if let favoriteFilm = try await dataService.getCachedFilm(by: id) {
            return favoriteFilm
        }
        
        // If not in favorites and we're online, we could fetch from network
        // But since we only cache favorites, we'll return nil for non-favorites
        return nil
    }
}

// MARK: - Favorite Methods

extension FilmService {
    
    func toggleFavorite(for film: Film) async throws -> Film {
        let isFavorite = try await dataService.isFavorite(filmId: film.id)
        
        if isFavorite {
            // Remove from favorites
            try await dataService.removeFromFavorites(filmId: film.id)
            return Film(
                id: film.id,
                brand: film.brand,
                model: film.model,
                slug: film.slug,
                type: film.type,
                color: film.color,
                iso: film.iso,
                image: film.image,
                yearStart: film.yearStart,
                yearEnd: film.yearEnd,
                country: film.country,
                description: film.description,
                purchaseLinks: film.purchaseLinks,
                isFavorite: false,
                isPopular: film.isPopular,
                isDead: film.isDead
            )
        } else {
            // Add to favorites
            try await dataService.addToFavorites(film)
            return Film(
                id: film.id,
                brand: film.brand,
                model: film.model,
                slug: film.slug,
                type: film.type,
                color: film.color,
                iso: film.iso,
                image: film.image,
                yearStart: film.yearStart,
                yearEnd: film.yearEnd,
                country: film.country,
                description: film.description,
                purchaseLinks: film.purchaseLinks,
                isFavorite: true,
                isPopular: film.isPopular,
                isDead: film.isDead
            )
        }
    }
    
    func getFavoriteFilms() async throws -> [Film] {
        return try await dataService.getFavoriteFilms()
    }
    
    func isFavorite(filmId: String) async throws -> Bool {
        return try await dataService.isFavorite(filmId: filmId)
    }
}

// MARK: - Brand Methods

extension FilmService {
    
    func fetchBrands(forceRefresh: Bool = false) async throws -> [String] {
        if networkService.isConnected && forceRefresh {
            // Try to fetch from network
            do {
                let brands = try await networkService.fetchBrands()
                try await dataService.saveBrands(brands)
                return brands
            } catch {
                let nsError = error as NSError
                if nsError.code == NSURLErrorCancelled {
                    print("🚫 Brands request cancelled, using cache")
                } else {
                    print("❌ Network brands fetch failed, falling back to cache: \(error)")
                }
            }
        }
        
        // Fetch from cache
        return try await dataService.getCachedBrands()
    }
}

// MARK: - Private Methods

private extension FilmService {
    
    func filterFavoritesByBrandAndSearch(_ favorites: [Film], brand: String?, searchText: String?) -> [Film] {
        var filtered = favorites
        
        // Filter by brand
        if let brand = brand, !brand.isEmpty {
            filtered = filtered.filter { $0.brand == brand }
        }
        
        // Filter by search text
        if let searchText = searchText, !searchText.isEmpty {
            let lowercaseSearch = searchText.lowercased()
            filtered = filtered.filter { film in
                film.model.lowercased().contains(lowercaseSearch) ||
                film.brand.lowercased().contains(lowercaseSearch)
            }
        }
        
        return filtered
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
            // For freshness, we'll sort by ID (assuming newer films have newer IDs)
            return films.sorted { ascending ? $0.id < $1.id : $0.id > $1.id }
        }
    }
}
