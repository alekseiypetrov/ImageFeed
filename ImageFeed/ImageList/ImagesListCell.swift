import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    static let activeImageOfLikeButton = UIImage(named: "Active")
    static let noActiveImageOfLikeButton = UIImage(named: "No Active")

    private let leftBackgroundColorOfImageView = UIColor(red: 174.0 / 255.0, green: 175.0 / 255.0, blue: 180.0 / 255.0, alpha: 1.0)
    private let rightBackgroundColorOfImageView = UIColor(red: 174.0 / 255.0, green: 175.0 / 255.0, blue: 180.0 / 255.0, alpha: 0.3)
    
    private let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer.colors = [
            leftBackgroundColorOfImageView.cgColor,
            rightBackgroundColorOfImageView.cgColor
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
