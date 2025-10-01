import UIKit

extension Date {
    static var safe: Date {
        if #available(iOS 15.0, *) {
            return Date.now
        } else {
            return Date()
        }
    }
}

final class ImagesListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let showSingleImageSegue = "ShowSingleImage"
    private let photoNames: [String] = Array(0..<20).map(String.init)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegue else {
            super.prepare(for: segue, sender: sender)
            return
        }
            
        guard
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            assertionFailure("Invalid segue destination or sender")
            return
        }
            
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            assertionFailure("Image not found for index \(indexPath.row)")
            return
        }
            
        viewController.image = image
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photoNames[indexPath.row] + ".jpg"
        guard let image = UIImage(named: imageName) else {
            cell.dateTitle.text = ""
            cell.likeButton.setImage(ImagesListCell.noActiveImageOfLikeButton, for: .normal)
            cell.showGradient()
            return
        }
        cell.hideGradient()
        cell.customImageView.image = image
        cell.dateTitle.text = dateFormatter.string(from: Date.safe)
        let settingImage = indexPath.row % 2 == 0 ? ImagesListCell.activeImageOfLikeButton : ImagesListCell.noActiveImageOfLikeButton
        cell.likeButton.setImage(settingImage, for: .normal)
    }
}


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoNames.count
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegue, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photoNames[indexPath.row] + ".jpg"
        guard let image = UIImage(named: imageName) else {
            return CGFloat(200.0)
        }
        
        let imageInset = UIEdgeInsets(top: 11, left: 20, bottom: 11, right: 20)
        let imageViewWidth = tableView.bounds.width - imageInset.left - imageInset.right
        
        let scale = imageViewWidth / image.size.width
        let imageHieght = image.size.height * scale + imageInset.top + imageInset.bottom
        return CGFloat(imageHieght)
    }
}
