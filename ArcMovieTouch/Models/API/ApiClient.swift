import Foundation
import Alamofire
import AlamofireObjectMapper

typealias ResponseBlock = (FetchMoviesResponse, Bool, Int) -> Void
typealias ErrorBlock = (Error?) -> Void
typealias FinishBlock = () -> Void

class ApiClient {

    static var shared = ApiClient()
    let apiKey = "1f54bd990f1cdfb230adb312546d765d"
    let apiLang = "en-US"
    let apiUrl = "https://api.themoviedb.org/3"

    private func buildApiUrl(endpoint: String, params: [String:String]?) -> String {
        var queryString = ""
        if let queryParams = params {
            for (key, value) in queryParams {
                queryString += "&\(key)=\(value)"
            }
        }
        return "\(apiUrl)/\(endpoint)?api_key=\(apiKey)\(queryString)"
    }

    func fetchMovies(page: Int = 1, forceRefresh: Bool = false, completion: @escaping ResponseBlock, fail: @escaping ErrorBlock, finish: @escaping FinishBlock) {
        let URL = buildApiUrl(endpoint: "movie/upcoming", params: ["page": forceRefresh ? "1" : String(page)])
        Alamofire.request(URL).responseObject { (response: DataResponse<FetchMoviesResponse>) in
            if let response = response.result.value {
                completion(response, forceRefresh, response.page)
            } else {
                fail(response.result.error)
            }
            finish()
        }
    }

    func fetchMovieDetail(movieId: Int, completion: @escaping (Movie) -> Void, fail: @escaping ErrorBlock, finish: @escaping FinishBlock) {
        let URL = buildApiUrl(endpoint: "movie/\(movieId)", params: nil)
        Alamofire.request(URL).responseObject { (response: DataResponse<Movie>) in
            if let movie = response.result.value {
                completion(movie)
            } else {
                fail(response.result.error)
            }
            finish()
        }
    }

    func fetchGenres(completion: @escaping ([Genre]) -> Void, fail: @escaping ErrorBlock, finish: @escaping FinishBlock) {
        let URL = buildApiUrl(endpoint: "genre/movie/list", params: nil)
        Alamofire.request(URL).responseArray(keyPath: "genres") { (response: DataResponse<[Genre]>) in
            if let response = response.result.value {
                completion(response)
            } else {
                fail(response.result.error)
            }
            finish()
        }
    }

}
