import Foundation
import SwiftData

@Model
final class CachedBrand {
    
    // MARK: - Properties
    
    @Attribute(.unique) var name: String
    var cachedAt: Date
    
    // MARK: - Initialization
    
    init(name: String) {
        self.name = name
        self.cachedAt = Date()
    }
}
