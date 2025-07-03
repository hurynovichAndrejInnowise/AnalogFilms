import SwiftUI
import SwiftData
import Swinject

@main
struct AnalogFilmsApp: App {
    
    // MARK: - Properties
    
    let modelContainer: ModelContainer = {
        let schema = Schema([CachedFilm.self, CachedBrand.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    // MARK: - Computed Properties
    
    private var container: Container {
        let container = ContainerFactory.createContainer()
        
        // Register ModelContext
        container.register(ModelContext.self) { _ in
            ModelContext(self.modelContainer)
        }.inObjectScope(.container)
        
        return container
    }
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environmentObject(ContainerWrapper(container: container))
        }
    }
}

// MARK: - Container Wrapper

class ContainerWrapper: ObservableObject {
    
    // MARK: - Properties
    
    let container: Container
    
    // MARK: - Initialization
    
    init(container: Container) {
        self.container = container
    }
}