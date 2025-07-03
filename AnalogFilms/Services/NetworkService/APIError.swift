import Foundation

enum APIError: Error, LocalizedError {
    
    // MARK: - Cases
    
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int)
    case noInternetConnection
    case timeout
    case unknown
    
    // MARK: - Computed Properties
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noInternetConnection:
            return "No internet connection"
        case .timeout:
            return "Request timeout"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
