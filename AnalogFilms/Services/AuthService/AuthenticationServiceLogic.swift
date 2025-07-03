import Foundation
import Combine

protocol AuthenticationServiceLogic {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    var authStatePublisher: AnyPublisher<User?, Never> { get }
    
    func login(email: String, password: String) async throws -> User
    func loginAsGuest() async -> User
    func logout() async
    func loadSavedUser() async
}