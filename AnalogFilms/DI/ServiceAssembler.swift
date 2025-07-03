import Foundation
import Swinject
import SwiftData

final class ServiceAssembler: Assembly {
    
    // MARK: - Assembly Protocol
    
    func assemble(container: Container) {
        registerDataService(in: container)
        registerNetworkService(in: container)
        registerFilmService(in: container)
        registerAuthenticationService(in: container)
    }
}

// MARK: - Private Methods

private extension ServiceAssembler {
    
    func registerDataService(in container: Container) {
        container.register(DataServiceLogic.self) { resolver in
            let modelContext = resolver.resolve(ModelContext.self)!
            return DataService(modelContext: modelContext)
        }.inObjectScope(.container)
    }
    
    func registerNetworkService(in container: Container) {
        container.register(NetworkServiceLogic.self) { _ in
            NetworkService()
        }.inObjectScope(.container)
    }
    
    func registerFilmService(in container: Container) {
        container.register(FilmServiceLogic.self) { resolver in
            FilmService(
                networkService: resolver.resolve(NetworkServiceLogic.self)!,
                dataService: resolver.resolve(DataServiceLogic.self)!
            )
        }.inObjectScope(.container)
    }
    
    func registerAuthenticationService(in container: Container) {
        container.register(AuthenticationServiceLogic.self) { _ in
            AuthenticationService()
        }.inObjectScope(.container)
    }
}