import Foundation
import ObjectMapper

class FetchMoviewResponse: Mappable {
    var results: [Movie] = []
    var page: Int = 0
    var totalResults: Int = 0
    var totalPages: Int = 1

    var overview: String = ""
    var releaseDate: String = ""

    required init?(map: Map){

    }

    func mapping(map: Map) {
        results <- map["results"]
        page <- map["page"]
        totalResults <- map["total_results"]
        totalPages <- map["total_pages"]
    }
}
