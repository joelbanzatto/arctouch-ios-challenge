import Foundation
import ObjectMapper

class Genre: Mappable {
    var identifier: Int = 0
    var name: String = ""

    required init?(map: Map){

    }

    func mapping(map: Map) {
        identifier <- map["id"]
        name <- map["name"]
    }
}
