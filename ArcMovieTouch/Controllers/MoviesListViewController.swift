import UIKit

class MoviesListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var apiResponse: FetchMoviewResponse?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        fetchData()
    }

    func fetchData() {
        fetchData(refresh: true, page: 1)
    }

    func fetchData(refresh: Bool = false, page: Int = 1) {
        ApiClient.shared.fetchMovies(completion: { [unowned self] response, hasMore, isRefreshing, page in
            self.apiResponse = response
        }, fail: { (error) in
            print(error ?? "no error description")
        }) { [unowned self] in
            self.tableView.reloadData()
        }
    }

}

extension MoviesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.apiResponse?.results.count else { return 0 }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.cellIdentifier, for: indexPath) as! MovieCell
        if let movie = apiResponse?.results[indexPath.row] {
            cell.bind(movie: movie)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: MovieCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: MovieCell.cellIdentifier)
    }
}
