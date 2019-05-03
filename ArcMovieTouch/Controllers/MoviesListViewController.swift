import UIKit

class MoviesListViewController: UITableViewController {

    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var refreshingActivity: UIActivityIndicatorView!

    private var apiResponse: FetchMoviesResponse?
    private var isLoading = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchData()
    }

    @IBAction func fetchData() {
        fetchData(refresh: true, page: 1)
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
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
            self.endTableViewRefreshing()
            self.refreshingActivity.stopAnimating()
            self.isLoading = false
        }
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        extendedLayoutIncludesOpaqueBars = true
        tableView.register(UINib(nibName: MovieCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: MovieCell.cellIdentifier)
    }

    func endTableViewRefreshing() {
        refreshControl?.endRefreshing()
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
