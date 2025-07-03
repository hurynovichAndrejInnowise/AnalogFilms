import Foundation

enum FilmSortField: String, CaseIterable {
    
    // MARK: - Cases
    
    case name = "name"
    case popularity = "popularity"
    case iso = "iso"
    case freshness = "freshness"
    
    // MARK: - Computed Properties
    
    var displayName: String {
        switch self {
        case .name:
            return "Name"
        case .popularity:
            return "Popularity"
        case .iso:
            return "ISO"
        case .freshness:
            return "Freshness"
        }
    }
}
