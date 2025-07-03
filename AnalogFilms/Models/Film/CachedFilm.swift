import Foundation
import SwiftData

@Model
final class CachedFilm {
    
    // MARK: - Basic Information
    
    @Attribute(.unique) var id: String
    var brand: String
    var model: String
    var slug: String
    
    // MARK: - Media
    
    var image: String?
    
    // MARK: - Film Characteristics
    
    var typeData: Data // Store array as Data
    var color: String
    var iso: String
    
    // MARK: - Production Information
    
    var yearStart: Int?
    var yearEnd: String?
    var country: String
    
    // MARK: - Description & Links
    
    var filmDescription: String
    var purchaseLinksData: Data // Store array as Data
    
    // MARK: - Status Flags
    
    var isDead: Bool
    var isPopular: Bool
    var isFavorite: Bool
    
    // MARK: - Cache Metadata
    
    var cachedAt: Date
    
    // MARK: - Initialization
    
    init(from film: Film) {
        self.id = film.id
        self.brand = film.brand
        self.model = film.model
        self.slug = film.slug
        
        self.image = film.image
        
        self.typeData = (try? JSONEncoder().encode(film.type)) ?? Data()
        self.color = film.color
        self.iso = film.iso
        
        self.yearStart = film.yearStart
        self.yearEnd = film.yearEnd
        self.country = film.country
        
        self.filmDescription = film.description
        self.purchaseLinksData = (try? JSONEncoder().encode(film.purchaseLinks)) ?? Data()
        
        self.isDead = film.isDead
        self.isPopular = film.isPopular
        self.isFavorite = film.isFavorite
        
        self.cachedAt = Date()
    }
}

// MARK: - Conversion Methods

extension CachedFilm {
    
    func toFilm() -> Film {
        let type = (try? JSONDecoder().decode([String].self, from: typeData)) ?? []
        let purchaseLinks = (try? JSONDecoder().decode([String].self, from: purchaseLinksData)) ?? []
        
        return Film(
            id: id,
            brand: brand,
            model: model,
            slug: slug,
            type: type,
            color: color,
            iso: iso,
            image: image,
            yearStart: yearStart,
            yearEnd: yearEnd,
            country: country,
            description: filmDescription,
            purchaseLinks: purchaseLinks,
            isFavorite: isFavorite,
            isPopular: isPopular,
            isDead: isDead
        )
    }
}
