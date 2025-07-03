import Foundation
import Combine
import Network

// MARK: - Network Service Implementation

final class NetworkService: NetworkServiceLogic {
    
    // MARK: - Properties
    
    private let baseURL = "https://www.analogfilm.club/api"
    private let session: URLSession
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isConnected = true
    
    // MARK: - Computed Properties
    
    lazy var networkStatusPublisher: AnyPublisher<NetworkStatus, Never> = {
        $isConnected
            .map { $0 ? .connected : .disconnected }
            .eraseToAnyPublisher()
    }()
    
    // MARK: - Initialization
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        startNetworkMonitoring()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Public Methods

extension NetworkService {
    
    func fetchFilms(
        brand: String?,
        sortOption: FilmSortOption,
        searchText: String?,
        limit: Int,
        offset: Int
    ) async throws -> FilmsDTO {
        guard isConnected else {
            throw APIError.noInternetConnection
        }
        
        var components = URLComponents(string: "\(baseURL)/films")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "sort", value: sortOption.apiValue)
        ]
        
        if let brand = brand, !brand.isEmpty {
            queryItems.append(URLQueryItem(name: "brand", value: brand))
        }
        
        if let searchText = searchText, !searchText.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: searchText))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        print("🌐 API Request URL: \(url.absoluteString)")
        print("📊 API Parameters:")
        print("   - Sort: \(sortOption.apiValue) (field: \(sortOption.field.rawValue), order: \(sortOption.order))")
        print("   - Brand: \(brand ?? "All")")
        print("   - Search: \(searchText ?? "None")")
        print("   - Limit: \(limit)")
        print("   - Offset: \(offset)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            
            do {
                return try decoder.decode(FilmsDTO.self, from: data)
            } catch {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let filmsArray = json["films"] as? [[String: Any]] ?? json["data"] as? [[String: Any]],
                       let total = json["total"] as? Int {
                        let filmsData = try JSONSerialization.data(withJSONObject: filmsArray)
                        let films = try decoder.decode([Film].self, from: filmsData)
                        return FilmsDTO(films: films, total: total)
                    } else {
                        throw APIError.decodingError(error)
                    }
                } catch {
                    throw APIError.decodingError(error)
                }
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchBrands() async throws -> [String] {
        guard isConnected else {
            throw APIError.noInternetConnection
        }
        
        guard let url = URL(string: "\(baseURL)/films/brands") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let brands = try JSONDecoder().decode([String].self, from: data)
            return brands
        } catch let error as APIError {
            throw error
        } catch {
            if error is DecodingError {
                throw APIError.decodingError(error)
            } else {
                throw APIError.networkError(error)
            }
        }
    }
}

// MARK: - Private Methods

private extension NetworkService {
    
    func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }
}
