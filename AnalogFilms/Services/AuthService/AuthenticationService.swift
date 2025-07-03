import Foundation
import Combine

final class AuthenticationService: AuthenticationServiceLogic, ObservableObject {
    
    // MARK: - Properties
    
    @Published private(set) var currentUser: User?
    
    // MARK: - Computed Properties
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    lazy var authStatePublisher: AnyPublisher<User?, Never> = {
        $currentUser.eraseToAnyPublisher()
    }()
    
    // MARK: - Private Properties
    
    private let userDefaultsKey = "lastLoggedInUser"
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Check credentials against local users
        guard let storedPassword = User.localPasswords[email],
              storedPassword == password else {
            throw AuthenticationError.invalidCredentials
        }
        
        guard let user = User.localUsers.first(where: { $0.email == email }) else {
            throw AuthenticationError.userNotFound
        }
        
        await MainActor.run {
            self.currentUser = user
            self.saveUserToDefaults(user)
        }
        
        return user
    }
    
    func loginAsGuest() async -> User {
        // Simulate slight delay for consistency
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let guestUser = User.guest
        
        await MainActor.run {
            self.currentUser = guestUser
            self.saveUserToDefaults(guestUser)
        }
        
        return guestUser
    }
    
    func logout() async {
        await MainActor.run {
            self.currentUser = nil
            self.clearSavedUser()
        }
    }
    
    func loadSavedUser() async {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            await MainActor.run {
                self.currentUser = user
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func saveUserToDefaults(_ user: User) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
    }
    
    private func clearSavedUser() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}