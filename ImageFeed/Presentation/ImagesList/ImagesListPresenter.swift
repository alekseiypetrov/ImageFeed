import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get set }
    
    func makeRequestForAnotherPage()
    func handlePhotosUpdatedNotification()
    func makeRequestToChangeLike(at row: Int, completion: @escaping (Result<Bool, Error>) -> Void)
    func getPhoto(at row: Int) -> Photo
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    var photosCount: Int {
        get {
            photos.count
        }
        set { }
    }
    
    // MARK: - Private Properties
    
    private enum ErrorReason: Error {
        case likeDidNotChanged
    }
    private var imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    // MARK: - Public Methods
    
    func makeRequestForAnotherPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func handlePhotosUpdatedNotification() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func makeRequestToChangeLike(at row: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let photo = photos[row]
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                completion(.failure(ErrorReason.likeDidNotChanged))
            case .success:
                self.photos = self.imagesListService.photos
                completion(.success(self.photos[row].isLiked))
            }
        }
    }
    
    func getPhoto(at row: Int) -> Photo {
        photos[row]
    }
}
