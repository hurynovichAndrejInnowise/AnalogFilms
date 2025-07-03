import Foundation

// MARK: - Film Filter

struct FilmFilter {
    
    // MARK: - Properties
    
    var searchText: String = ""
    var selectedBrand: String? = nil
    var sortOption: FilmSortOption = .popularityDesc
    
    // MARK: - Computed Properties
    
    var hasActiveFilters: Bool {
        !searchText.isEmpty || selectedBrand != nil
    }
    
    // MARK: - Methods
    
    mutating func reset() {
        searchText = ""
        selectedBrand = nil
        sortOption = .popularityDesc
    }
    
    func isEmpty() -> Bool {
        return searchText.isEmpty && selectedBrand == nil
    }
}