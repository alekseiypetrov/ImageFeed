import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    static let activeImageOfLikeButton = UIImage(named: "Active")
    static let noActiveImageOfLikeButton = UIImage(named: "No Active")
    
    private let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer.colors = [
            Colors.leftBackgroundColorOfImageView.cgColor,
            Colors.rightBackgroundColorOfImageView.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 0, y: 0.5)
        customImageView.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = customImageView.bounds
    }
    
    func showGradient() {
        gradientLayer.isHidden = false
    }
    
    func hideGradient() {
        gradientLayer.isHidden = true
    }
}
