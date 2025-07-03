import Foundation

protocol Coordinator: ObservableObject {
    associatedtype Route
    
    // MARK: - Properties
    
    var path: [Route] { get set }
    
    // MARK: - Methods
    
    func navigate(to route: Route)
    func navigateBack()
    func navigateToRoot()
}
