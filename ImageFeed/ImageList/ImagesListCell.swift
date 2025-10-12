import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.kf.cancelDownloadTask()
    }
}
