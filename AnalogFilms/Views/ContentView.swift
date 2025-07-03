import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    enum AppState {
        case splash
        case login
        case authenticated
    }
    
    @Published var currentState: AppState = .splash
    private var authService: AuthenticationServiceLogic?
    private var cancellables = Set<AnyCancellable>()
    
    func initialize(authService: AuthenticationServiceLogic) {
        self.authService = authService
        
        // Listen to auth state changes
        authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if user != nil {
                    self?.currentState = .authenticated
                } else {
                    if self?.currentState == .authenticated {
                        // User logged out
                        self?.currentState = .login
                    }
                }
            }
            .store(in: &cancellables)
        
        // Try to load saved user after splash
        Task {
            await authService.loadSavedUser()
        }
    }
    
    func completeSplash() {
        if authService?.isAuthenticated == true {
            currentState = .authenticated
        } else {
            currentState = .login
        }
    }
    
    func completeLogin() {
        currentState = .authenticated
    }
    
    func logout() {
        Task {
            await authService?.logout()
            await MainActor.run {
                currentState = .login
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var appStateManager = AppStateManager()
    @EnvironmentObject private var containerWrapper: ContainerWrapper
    
    var body: some View {
        Group {
            switch appStateManager.currentState {
            case .splash:
                SplashView {
                    appStateManager.completeSplash()
                }
                
            case .login:
                LoginView {
                    appStateManager.completeLogin()
                }
                
            case .authenticated:
                FilmsListView()
                    .environmentObject(appStateManager)
            }
        }
        .onAppear {
            if let authService = containerWrapper.container.resolve(AuthenticationServiceLogic.self) {
                appStateManager.initialize(authService: authService)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appStateManager.currentState)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(ContainerWrapper(container: ContainerFactory.createContainer()))
}