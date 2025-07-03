import Foundation
import SwiftUI

@Observable
final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var path: [AppRoute] = []
    
    // MARK: - Methods
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToRoot() {
        path.removeAll()
    }
}
