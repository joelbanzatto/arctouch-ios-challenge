import UIKit

class MovieCell: UITableViewCell {

    public weak var movie: Movie!

    static var cellIdentifier: String {
        get {
            let filePath = URL(string: #file)!.deletingPathExtension()
            return filePath.lastPathComponent
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
