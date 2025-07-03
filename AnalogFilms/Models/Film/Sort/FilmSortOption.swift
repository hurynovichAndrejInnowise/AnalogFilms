import Foundation

struct FilmSortOption: Equatable, Hashable {
    
    // MARK: - Properties
    
    let field: FilmSortField
    let order: SortOrder
    
    // MARK: - Computed Properties
    
    var apiValue: String {
        return order == .reverse ? "\(field.rawValue)-desc" : field.rawValue
    }
    
    var displayName: String {
        let orderSymbol = order == .forward ? "↑" : "↓"
        return "\(field.displayName) \(orderSymbol)"
    }
}

// MARK: - Static Constants

extension FilmSortOption {
    
    static let nameAsc = FilmSortOption(field: .name, order: .forward)
    static let nameDesc = FilmSortOption(field: .name, order: .reverse)
    static let popularityAsc = FilmSortOption(field: .popularity, order: .forward)
    static let popularityDesc = FilmSortOption(field: .popularity, order: .reverse)
    static let isoAsc = FilmSortOption(field: .iso, order: .forward)
    static let freshnessAsc = FilmSortOption(field: .freshness, order: .forward)
    static let freshnessDesc = FilmSortOption(field: .freshness, order: .reverse)
    
    static let allOptions: [FilmSortOption] = [
        .nameAsc, .nameDesc,
        .popularityAsc, .popularityDesc,
        .freshnessAsc, .freshnessDesc,
        .isoAsc
    ]
}
