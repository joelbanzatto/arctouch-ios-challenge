import UIKit

class MoviesListViewController: UITableViewController {

    private var apiResponse: FetchMoviewResponse?

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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiClient.shared.fetchMovies(completion: { [unowned self] response, hasMore, isRefreshing, page in
            self.apiResponse = response
        }, fail: { (error) in
            print(error ?? "no error description")
        }) { [unowned self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
                self.endTableViewRefreshing()
            }
        }
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
}
