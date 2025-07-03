import Foundation

enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case userNotFound
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .networkError:
            return "Network connection error"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}