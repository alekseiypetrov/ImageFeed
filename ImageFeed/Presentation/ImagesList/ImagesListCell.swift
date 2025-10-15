import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Constants
    
    private enum Constants {
        static let activeLike = UIImage(named: "Active")
        static let noActiveLike = UIImage(named: "No Active")
    }
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Public Properties
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Outlets
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likeButton.accessibilityIdentifier = "like button"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.kf.cancelDownloadTask()
    }
    
    // MARK: - Actions
    
    @IBAction private func didTappedLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public Methods
    
    func setIsLiked(flag isLiked: Bool) {
        let settingImage = isLiked ? Constants.activeLike : Constants.noActiveLike
        likeButton.setImage(settingImage, for: .normal)
    }
}
