import Foundation
import ObjectMapper

enum ImageSize: String {
    case hd = "original"
    case sd = "w500"
}

class Movie: Mappable {
    var identifier: Int = 0
    var title: String = ""
    var posterPath: String?
    var backdropPath: String?
    var genres: [Genre]?
    var genreIds: [Int] = []

    var overview: String = ""
    var releaseDate: String = ""

    var genresText: String {
        return genres?.map({ genre in
            return genre.name
        }).joined(separator: ", ") ?? "--"
    }

    required init?(map: Map){

    }

    func mapping(map: Map) {
        identifier <- map["id"]
        title <- map["title"]
        posterPath <- map["poster_path"]
        backdropPath <- map["backdrop_path"]
        genres <- map["genres"]
        genreIds <- map["genre_ids"]
        overview <- map["overview"]
        releaseDate <- map["release_date"]
    }

    func getPoster(size: ImageSize) -> URL? {
        return buildImageURL(imagePath: posterPath ?? "", size: size)
    }

    func getBackdrop(size: ImageSize) -> URL? {
        return buildImageURL(imagePath: backdropPath ?? "", size: size)
    }

    private func buildImageURL(imagePath: String, size: ImageSize) -> URL? {
        return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)/\(imagePath)")
    }
}
