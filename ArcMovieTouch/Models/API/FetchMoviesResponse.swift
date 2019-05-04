import Foundation
import ObjectMapper

class FetchMoviesResponse: Mappable {
    static var empty = FetchMoviesResponse(JSON: [:])
    
    var results: [Movie] = []
    var page: Int = 0
    var totalResults: Int = 0
    var totalPages: Int = 1

    var overview: String = ""
    var releaseDate: String = ""

    var hasMore: Bool {
        return page < totalPages
    }

    required init?(map: Map){

    }

    func mapping(map: Map) {
        results <- map["results"]
        page <- map["page"]
        totalResults <- map["total_results"]
        totalPages <- map["total_pages"]
    }
}
