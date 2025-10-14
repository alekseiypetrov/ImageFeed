import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Constants
    
    private enum Constants {
        static let placeholder = UIImage(named: "stub")
        static let activeImageOfLikeButton = UIImage(named: "Active")
        static let noActiveImageOfLikeButton = UIImage(named: "No Active")
        static let showSingleImageSegue = "ShowSingleImage"
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Properties
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        presenter?.makeRequestForAnotherPage()
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
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
            
        guard let photo = presenter?.getPhoto(at: indexPath.row),
              let imageUrl = URL(string: photo.largeImageURL) else {
            assertionFailure("Image not found for index \(indexPath.row)")
            return
        }
        viewController.imageUrl = imageUrl
    }
    
    // MARK: - Public Methods
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    // MARK: - Private Methods
    
    private func setupObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.presenter?.handlePhotosUpdatedNotification()
            })
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        guard let photo = presenter?.getPhoto(at: indexPath.row) else {
            return
        }

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
        UIBlockingProgressHUD.show()
        presenter?.makeRequestToChangeLike(at: indexPath.row) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
            case .success(let likeStatus):
                cell.setIsLiked(flag: likeStatus)
                print("[ImagesListViewController/imageListCellDidTapLike]: Лайк изменен.")
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось изменить информацию о фотографии",
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        self.present(alert, animated: true)
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
        guard let count = presenter?.photosCount else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let count = presenter?.photosCount,
           indexPath.row + 1 == count {
            presenter?.makeRequestForAnotherPage()
        }
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.showSingleImageSegue, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let count = presenter?.photosCount,
              count > 0,
              let photo = presenter?.getPhoto(at: indexPath.row) else {
            return CGFloat(400.0)
        }

        let imageSize = photo.size
        let imageInset = UIEdgeInsets(top: 11, left: 20, bottom: 11, right: 20)
        let imageViewWidth = tableView.bounds.width - imageInset.left - imageInset.right
        
        let scale = imageViewWidth / imageSize.width
        let imageHeight = imageSize.height * scale + imageInset.top + imageInset.bottom
        return CGFloat(imageHeight)
    }
}
