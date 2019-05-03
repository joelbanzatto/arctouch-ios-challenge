import UIKit
import Kingfisher

class MovieCell: UITableViewCell {
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!

    static var cellIdentifier: String {
        get {
            let filePath = URL(string: #file)!.deletingPathExtension()
            return filePath.lastPathComponent
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        posterImageView.layer.shadowColor = UIColor.black.cgColor
        posterImageView.layer.shadowRadius = 8
        posterImageView.layer.shadowOpacity = 0.7
        posterImageView.layer.shadowPath = UIBezierPath(rect: posterImageView.bounds).cgPath
    }

    public func bind(movie: Movie) {
        backdropImageView.kf.setImage(with: movie.getBackdrop(size: .sd))
        posterImageView.kf.setImage(with: movie.getPoster(size: .sd))
        titleLabel.text = movie.title
        releaseDateLabel.text = movie.releaseDate
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
}
