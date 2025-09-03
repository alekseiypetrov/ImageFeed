import UIKit

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
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
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row] + ".jpg"
        guard let image = UIImage(named: imageName) else {
            cell.dateTitle.text = ""
            cell.likeButton.setImage(ImagesListCell.noActiveImageOfLikeButton, for: .normal)
            cell.showGradient()
            return
        }
        cell.hideGradient()
        cell.customImageView.image = image
        cell.dateTitle.text = dateFormatter.string(from: Date.now)
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
        return photosName.count
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photosName[indexPath.row] + ".jpg"
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
