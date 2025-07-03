import Foundation
import Combine

@Observable
final class FilmDetailViewModel {
    
    // MARK: - Properties
    var film: Film
    var isLoading = false
    var errorMessage: String?
    var showError = false
    
    // MARK: - Private Properties
    private let filmService: FilmServiceLogic
    private var onFilmUpdated: ((Film) -> Void)?
    
    // MARK: - Initialization
    init(film: Film, filmService: FilmServiceLogic) {
        self.film = film
        self.filmService = filmService
    }
}

// MARK: - Public Methods
extension FilmDetailViewModel {
    @MainActor
    func refreshFilm() async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            if let updatedFilm = try await filmService.getFilm(by: film.id) {
                self.film = updatedFilm
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    func toggleFavorite() async {
        do {
            let updatedFilm = try await filmService.toggleFavorite(for: film)
            self.film = updatedFilm
            
            if let onFilmUpdated = onFilmUpdated {
                onFilmUpdated(updatedFilm)
            }
        } catch {
            self.errorMessage = "Failed to update favorite: \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    func setUpdateCallback(_ callback: @escaping (Film) -> Void) {
        self.onFilmUpdated = callback
    }
}
