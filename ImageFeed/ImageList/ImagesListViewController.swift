import UIKit
import Kingfisher

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
    private enum Constants {
        static let placeholder = UIImage(named: "stub")
        static let activeImageOfLikeButton = UIImage(named: "Active")
        static let noActiveImageOfLikeButton = UIImage(named: "No Active")
        static let showSingleImageSegue = "ShowSingleImage"
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private var imagesListServiceObserver: NSObjectProtocol?
    private var imagesListService = ImagesListService.shared
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        getNewPhotos()
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    private func getNewPhotos() {
        imagesListService.fetchPhotosNextPage()
    }
    
    private func setupObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: {[weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            })
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.showSingleImageSegue else {
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
            
        guard let imageUrl = URL(string: photos[indexPath.row].largeImageURL) else {
            assertionFailure("Image not found for index \(indexPath.row)")
            return
        }
        viewController.imageUrl = imageUrl
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.delegate = self

        cell.customImageView.contentMode = .center
        cell.customImageView.clipsToBounds = false
        cell.customImageView.backgroundColor = .ypGrey
        cell.customImageView.kf.indicatorType = .activity
        let imageUrl = URL(string: photo.thumbImageURL)
        cell.customImageView.kf.setImage(
            with: imageUrl,
            placeholder: Constants.placeholder,
            completionHandler: {result in
                switch result {
                case .failure:
                    break
                case .success:
                    cell.customImageView.contentMode = .scaleAspectFill
                    cell.customImageView.clipsToBounds = true
                    break
                }
            }
        )
        
        let settingImage = photo.isLiked ? Constants.activeImageOfLikeButton : Constants.noActiveImageOfLikeButton
        cell.likeButton.setImage(settingImage, for: .normal)

        if let createdAt = photo.createdAt {
            cell.dateTitle.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateTitle.text = dateFormatter.string(from: Date.safe)
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {[weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Не удалось изменить информацию о фотографии",
                    preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(title: "OK", style: .default)
                )
                self.present(alert, animated: true)
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(flag: self.photos[indexPath.row].isLiked)
                print("[ImagesListViewController/imageListCellDidTapLike]: Лайк изменен.")
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            getNewPhotos()
        }
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.showSingleImageSegue, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if photos.count == 0 {
            return CGFloat(400.0)
        }

        let imageSize = photos[indexPath.row].size
        let imageInset = UIEdgeInsets(top: 11, left: 20, bottom: 11, right: 20)
        let imageViewWidth = tableView.bounds.width - imageInset.left - imageInset.right
        
        let scale = imageViewWidth / imageSize.width
        let imageHeight = imageSize.height * scale + imageInset.top + imageInset.bottom
        return CGFloat(imageHeight)
    }
}
