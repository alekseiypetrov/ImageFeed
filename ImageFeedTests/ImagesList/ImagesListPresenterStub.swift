@testable import ImageFeed

final class ImagesListPresenterStub: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photosCount: Int {
        get {
            photos.count
        }
        set { }
    }
    var photos: [Photo] = []
    var isEqualOldCountAndNewCount: Bool = false
    
    func makeRequestForAnotherPage() { }
    
    func handlePhotosUpdatedNotification() {
        if isEqualOldCountAndNewCount {
            view?.updateTableViewAnimated(oldCount: 1, newCount: 1)
        }
    }
    
    func makeRequestToChangeLike(at row: Int, completion: @escaping (Result<Bool, Error>) -> Void) { }
    
    func getPhoto(at row: Int) -> Photo {
        photos[row]
    }
}
