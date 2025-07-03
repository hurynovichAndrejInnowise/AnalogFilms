import Foundation
import Combine

// MARK: - Network Service Protocol
protocol NetworkServiceLogic {
    
    // MARK: - Properties
    
    var isConnected: Bool { get }
    var networkStatusPublisher: AnyPublisher<NetworkStatus, Never> { get }
    
    // MARK: - Methods
    
    func fetchFilms(
        brand: String?,
        sortOption: FilmSortOption,
        searchText: String?,
        limit: Int,
        offset: Int
    ) async throws -> FilmsDTO
    
    func fetchBrands() async throws -> [String]
}
