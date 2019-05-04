import UIKit

class MoviesListViewController: UITableViewController {

    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var refreshingActivity: UIActivityIndicatorView!

    private var apiResponse: FetchMoviesResponse?
    private var genres: [Genre] = []
    private var isLoading = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    @IBAction func fetchData() {
        self.genres = []
        self.apiResponse = FetchMoviesResponse.empty
        updateState()

        ApiClient.shared.fetchGenres(completion: { [unowned self] genres in
            self.genres = genres
        }, fail: { (error) in
            print(error ?? "error with no description")
        }) { [unowned self] in
            self.fetchData(refresh: true, page: 1)
        }
    }

    func fetchData(refresh: Bool = false, page: Int = 1) {
        isLoading = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiClient.shared.fetchMovies(page: page, forceRefresh: refresh, completion: { [unowned self] response, isRefreshing, page in
            if isRefreshing {
                self.apiResponse = response
            } else {
                var allResults = self.apiResponse?.results ?? []
                allResults.append(contentsOf: response.results)
                self.apiResponse = response
                self.apiResponse?.results = allResults
            }
        }, fail: { (error) in
            print(error ?? "no error description")
        }) { [unowned self] in
            self.reduceGenders()
            self.updateState()
        }
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        extendedLayoutIncludesOpaqueBars = true
        tableView.register(UINib(nibName: MovieCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: MovieCell.cellIdentifier)
    }

    func reduceGenders() {
        guard let movies = self.apiResponse?.results else { return }
        self.apiResponse?.results = movies.map { [unowned self] movie in
            let movieGenres = movie.genreIds
            movie.genres = self.genres.filter { g in
                return movieGenres.firstIndex(where: { g2 in
                    return g2 == g.identifier
                }) != nil
            }
            return movie
        }
    }

    func endTableViewRefreshing() {
        refreshControl?.endRefreshing()
    }

    func updateState() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        tableView.reloadData()
        endTableViewRefreshing()
        refreshingActivity.stopAnimating()
        isLoading = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.apiResponse?.results.count else { return 0 }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.cellIdentifier, for: indexPath) as! MovieCell
        if let movie = apiResponse?.results[indexPath.row] {
            cell.bind(movie: movie)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let visibleAreaHeight = tableView.contentSize.height - tableView.bounds.height

        if let response = apiResponse {
            if offsetY >= visibleAreaHeight - 80 && response.hasMore && !isLoading {
                refreshingActivity.startAnimating()
                fetchData(refresh: false, page: response.page + 1)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let movie = apiResponse?.results[indexPath.row] else { return }
        performSegue(withIdentifier: "MovieDetailSegue", sender: movie)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "MovieDetailSegue" {
            if let movie = sender as? Movie {
                let vc = segue.destination as! MovieDetailViewController
                vc.movie = movie
            }
        }
    }
}
