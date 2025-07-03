import Foundation

// MARK: - Data Service Protocol
protocol DataServiceLogic {
    
    // MARK: - Film Methods
    
    func saveFilms(_ films: [Film]) async throws
    func getCachedFilms(
        brand: String?,
        sortOption: FilmSortOption,
        limit: Int,
        offset: Int
    ) async throws -> [Film]
    func getCachedFilm(by id: String) async throws -> Film?
    func getTotalCachedFilmsCount() async throws -> Int
    
    // MARK: - Favorite Methods
    
    func getFavoriteFilms() async throws -> [Film]
    func addToFavorites(_ film: Film) async throws
    func removeFromFavorites(filmId: String) async throws
    func isFavorite(filmId: String) async throws -> Bool
    
    // MARK: - Brand Methods
    
    func saveBrands(_ brands: [String]) async throws
    func getCachedBrands() async throws -> [String]
    
    // MARK: - Cache Management
    
    func clearOldCache() async throws
}
