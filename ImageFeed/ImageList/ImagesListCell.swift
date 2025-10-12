import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    private enum Constants {
        static let activeLike = UIImage(named: "Active")
        static let noActiveLike = UIImage(named: "No Active")
    }
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.kf.cancelDownloadTask()
    }
    
    @IBAction func didTappedLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(flag isLiked: Bool) {
        let settingImage = isLiked ? Constants.activeLike : Constants.noActiveLike
        likeButton.setImage(settingImage, for: .normal)
    }
}
