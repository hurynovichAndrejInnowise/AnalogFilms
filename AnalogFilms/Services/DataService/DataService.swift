import Foundation
import SwiftData

final class DataService: DataServiceLogic {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - Film Methods

extension DataService {
    
    func saveFilms(_ films: [Film]) async throws {
        // This method is now primarily used for syncing existing favorites
        await MainActor.run {
            do {
                // Only save films that are marked as favorites
                let favoriteFilms = films.filter { $0.isFavorite }
                
                for film in favoriteFilms {
                    // Check if film already exists
                    let fetchDescriptor = FetchDescriptor<CachedFilm>(
                        predicate: #Predicate<CachedFilm> { cachedFilm in
                            cachedFilm.id == film.id
                        }
                    )
                    
                    let existingFilms = try modelContext.fetch(fetchDescriptor)
                    
                    if let existingFilm = existingFilms.first {
                        // Update existing film
                        existingFilm.isFavorite = true
                        existingFilm.cachedAt = Date()
                    } else {
                        // Insert new favorite film
                        let cachedFilm = CachedFilm(from: film)
                        cachedFilm.isFavorite = true
                        modelContext.insert(cachedFilm)
                    }
                }
                
                try modelContext.save()
            } catch {
                print("Error saving films: \(error)")
            }
        }
    }
    
    func getCachedFilms(
        brand: String?,
        sortOption: FilmSortOption,
        limit: Int,
        offset: Int
    ) async throws -> [Film] {
        return await MainActor.run {
            // Only return favorite films
            var predicate: Predicate<CachedFilm>?
            
            if let brand = brand, !brand.isEmpty {
                predicate = #Predicate<CachedFilm> { film in
                    film.brand == brand && film.isFavorite
                }
            } else {
                predicate = #Predicate<CachedFilm> { film in
                    film.isFavorite
                }
            }
            
            var fetchDescriptor = FetchDescriptor<CachedFilm>(
                predicate: predicate
            )
            fetchDescriptor.fetchLimit = limit
            fetchDescriptor.fetchOffset = offset
            
            do {
                let cachedFilms = try modelContext.fetch(fetchDescriptor)
                let films = cachedFilms.compactMap { $0.toFilm() }
                
                // Apply sorting in memory since SwiftData sorting is complex
                return self.sortFilms(films, by: sortOption)
            } catch {
                print("Error fetching cached films: \(error)")
                return []
            }
        }
    }
    
    func getCachedFilm(by id: String) async throws -> Film? {
        return await MainActor.run {
            let fetchDescriptor = FetchDescriptor<CachedFilm>(
                predicate: #Predicate<CachedFilm> { film in
                    film.id == id
                }
            )
            
            do {
                let cachedFilms = try modelContext.fetch(fetchDescriptor)
                return cachedFilms.first?.toFilm()
            } catch {
                print("Error fetching cached film: \(error)")
                return nil
            }
        }
    }
    
    func getTotalCachedFilmsCount() async throws -> Int {
        return await MainActor.run {
            let fetchDescriptor = FetchDescriptor<CachedFilm>(
                predicate: #Predicate<CachedFilm> { film in
                    film.isFavorite
                }
            )
            
            do {
                let count = try modelContext.fetchCount(fetchDescriptor)
                return count
            } catch {
                print("Error getting cached films count: \(error)")
                return 0
            }
        }
    }
}

// MARK: - Favorite Methods

extension DataService {
    
    func getFavoriteFilms() async throws -> [Film] {
        return await MainActor.run {
            let fetchDescriptor = FetchDescriptor<CachedFilm>(
                predicate: #Predicate<CachedFilm> { film in
                    film.isFavorite
                }
            )
            
            do {
                let cachedFilms = try modelContext.fetch(fetchDescriptor)
                return cachedFilms.compactMap { $0.toFilm() }
            } catch {
                print("Error fetching favorite films: \(error)")
                return []
            }
        }
    }
    
    func addToFavorites(_ film: Film) async throws {
        try await MainActor.run {
            do {
                // Check if film already exists
                let fetchDescriptor = FetchDescriptor<CachedFilm>(
                    predicate: #Predicate<CachedFilm> { cachedFilm in
                        cachedFilm.id == film.id
                    }
                )
                
                let existingFilms = try modelContext.fetch(fetchDescriptor)
                
                if let existingFilm = existingFilms.first {
                    // Update existing film to be favorite
                    existingFilm.isFavorite = true
                    existingFilm.cachedAt = Date()
                } else {
                    // Create new favorite film
                    var favoriteFilm = film
                    // Create a new Film instance with isFavorite = true
                    favoriteFilm = Film(
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
                    
                    let cachedFilm = CachedFilm(from: favoriteFilm)
                    modelContext.insert(cachedFilm)
                }
                
                try modelContext.save()
            } catch {
                print("Error adding film to favorites: \(error)")
                throw error
            }
        }
    }
    
    func removeFromFavorites(filmId: String) async throws {
        try await MainActor.run {
            do {
                let fetchDescriptor = FetchDescriptor<CachedFilm>(
                    predicate: #Predicate<CachedFilm> { film in
                        film.id == filmId
                    }
                )
                
                let films = try modelContext.fetch(fetchDescriptor)
                
                for film in films {
                    modelContext.delete(film)
                }
                
                try modelContext.save()
            } catch {
                print("Error removing film from favorites: \(error)")
                throw error
            }
        }
    }
    
    func isFavorite(filmId: String) async throws -> Bool {
        return await MainActor.run {
            let fetchDescriptor = FetchDescriptor<CachedFilm>(
                predicate: #Predicate<CachedFilm> { film in
                    film.id == filmId && film.isFavorite
                }
            )
            
            do {
                let count = try modelContext.fetchCount(fetchDescriptor)
                return count > 0
            } catch {
                print("Error checking if film is favorite: \(error)")
                return false
            }
        }
    }
}

// MARK: - Brand Methods

extension DataService {
    
    func saveBrands(_ brands: [String]) async throws {
        await MainActor.run {
            // Clear existing brands
            let fetchDescriptor = FetchDescriptor<CachedBrand>()
            do {
                let existingBrands = try modelContext.fetch(fetchDescriptor)
                for brand in existingBrands {
                    modelContext.delete(brand)
                }
                
                // Insert new brands
                for brandName in brands {
                    let cachedBrand = CachedBrand(name: brandName)
                    modelContext.insert(cachedBrand)
                }
                
                try modelContext.save()
            } catch {
                print("Error saving brands: \(error)")
            }
        }
    }
    
    func getCachedBrands() async throws -> [String] {
        return await MainActor.run {
            let fetchDescriptor = FetchDescriptor<CachedBrand>()
            
            do {
                let cachedBrands = try modelContext.fetch(fetchDescriptor)
                return cachedBrands.map { $0.name }.sorted()
            } catch {
                print("Error fetching cached brands: \(error)")
                return []
            }
        }
    }
}

// MARK: - Cache Management

extension DataService {
    
    func clearOldCache() async throws {
        await MainActor.run {
            let oldDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            
            let filmDescriptor = FetchDescriptor<CachedFilm>(
                predicate: #Predicate<CachedFilm> { film in
                    film.cachedAt < oldDate && !film.isFavorite
                }
            )
            
            let brandDescriptor = FetchDescriptor<CachedBrand>(
                predicate: #Predicate<CachedBrand> { brand in
                    brand.cachedAt < oldDate
                }
            )
            
            do {
                let oldFilms = try modelContext.fetch(filmDescriptor)
                let oldBrands = try modelContext.fetch(brandDescriptor)
                
                for film in oldFilms {
                    modelContext.delete(film)
                }
                
                for brand in oldBrands {
                    modelContext.delete(brand)
                }
                
                try modelContext.save()
            } catch {
                print("Error clearing old cache: \(error)")
            }
        }
    }
}

// MARK: - Private Methods

private extension DataService {
    
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
