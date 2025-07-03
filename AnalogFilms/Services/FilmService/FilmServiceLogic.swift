import Foundation
import Combine

// MARK: - Film Service Protocol
protocol FilmServiceLogic {
    
    // MARK: - Properties
    
    var isConnected: Bool { get }
    var networkStatusPublisher: AnyPublisher<NetworkStatus, Never> { get }
    
    // MARK: - Methods
    
    func fetchFilms(
        brand: String?,
        sortOption: FilmSortOption,
        searchText: String?,
        limit: Int,
        offset: Int,
        forceRefresh: Bool
    ) async throws -> FilmsDTO
    
    func fetchBrands(forceRefresh: Bool) async throws -> [String]
    func getFilm(by id: String) async throws -> Film?
    
    // MARK: - Favorite Methods
    
    func toggleFavorite(for film: Film) async throws -> Film
    func getFavoriteFilms() async throws -> [Film]
    func isFavorite(filmId: String) async throws -> Bool
}
