import UIKit

class MoviesListViewController: UITableViewController, UIAlertViewDelegate {

    @IBOutlet weak var refreshingActivity: UIActivityIndicatorView!

    private var apiResponse: FetchMoviesResponse?
    private var genres: [Genre] = []
    private var isLoading = false
    public var searchTerm: String?

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
        setup()
    }

    @IBAction func fetchData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
        ApiClient.shared.fetchMovies(page: page, forceRefresh: refresh, keyword: searchTerm, completion: { [unowned self] response, isRefreshing, page in
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateState()
            }
        }
    }

    func setup() {
        if (searchTerm ?? "").lengthOfBytes(using: .utf8) > 0 {
            self.navigationItem.title = "Searching for \"\(searchTerm ?? "")\""
            self.navigationItem.rightBarButtonItem = nil
            self.navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), landscapeImagePhone: UIImage(named: "back"), style: .plain, target: self, action: #selector(goBack))
        } else {
            self.navigationItem.title = "Upcoming Movies"
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationController?.isNavigationBarHidden = false
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

    func updateState(_ refreshing: Bool = false) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        endTableViewRefreshing()
        refreshingActivity.stopAnimating()
        isLoading = false
        tableView.reloadData()
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1), animated: false)
    }

    @objc func goBack() {
        navigationController?.popViewController(animated: true)
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

    @IBAction func searchButtonPressed() {
        let alert = UIAlertController(title: "Search by movie title", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addTextField(configurationHandler: { [unowned self] textField in
            textField.placeholder = "Type something like \"new job\"..."
            textField.text = self.searchTerm ?? ""
            textField.tintColor = .black
        })
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [unowned self] action in
            if let name = alert.textFields?.first?.text, name.trimmingCharacters(in: .whitespacesAndNewlines).lengthOfBytes(using: .utf8) > 0 {
                self.openSearchResultsScreen(name)
            }
        }))
        alert.view.tintColor = .red
        self.present(alert, animated: true)
    }

    func openSearchResultsScreen(_ query: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MoviesListViewController") as! MoviesListViewController
        vc.searchTerm = query
        navigationController?.pushViewController(vc, animated: true)
    }
}
