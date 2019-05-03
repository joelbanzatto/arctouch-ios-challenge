import UIKit
import Kingfisher

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!

    var movie: Movie!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchDetail()
    }

    func fetchDetail() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiClient.shared.fetchMovieDetail(movieId: movie.identifier, completion: { [unowned self] movie in
            self.movie = movie
        }, fail: { (error) in
            print(error ?? "no error description")
        }) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.bind()
        }
    }

    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }

    func setup() {
        navigationController?.isNavigationBarHidden = true
        posterImageView.layer.borderColor = UIColor.lightGray.cgColor
        posterImageView.layer.borderWidth = 1
    }

    func bind() {
        posterImageView.kf.setImage(with: movie.getPoster(size: .hd))
        backdropImageView.kf.setImage(with: movie.getBackdrop(size: .hd))
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        releaseDateLabel.text = movie.releaseDate
        genresLabel.text = movie.genresText
    }
}
