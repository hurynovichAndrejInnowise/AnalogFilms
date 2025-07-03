import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let name: String
    let isGuest: Bool
    
    static let guest = User(
        id: "guest",
        email: "guest@analogfilms.com",
        name: "Guest User",
        isGuest: true
    )
    
    // Local test users
    static let localUsers: [User] = [
        User(id: "admin", email: "admin@analogfilms.com", name: "Admin User", isGuest: false),
        User(id: "user1", email: "user@test.com", name: "Test User", isGuest: false),
        User(id: "demo", email: "demo@demo.com", name: "Demo User", isGuest: false)
    ]
    
    static let localPasswords: [String: String] = [
        "admin@analogfilms.com": "admin123",
        "user@test.com": "password",
        "demo@demo.com": "demo"
    ]
}