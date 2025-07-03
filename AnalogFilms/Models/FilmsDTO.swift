import Foundation

// MARK: - Films Data Transfer Object

struct FilmsDTO: Codable {
    
    // MARK: - Properties
    
    let films: [Film]
    let total: Int
}