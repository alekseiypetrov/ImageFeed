@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photosCount: Int {
        get {
            photos.count
        }
        set { }
    }
    var photos: [Photo] = []
    var didMakeRequestForAnotherPage: Bool = false
    var didMakeRequestToChangeLike: Bool = false
    var isResponseSuccess: Bool = true
    private enum TestError: Error {
        case testError
    }
    
    func makeRequestForAnotherPage() {
        didMakeRequestForAnotherPage = true
    }
    
    func handlePhotosUpdatedNotification() { }
    
    func makeRequestToChangeLike(at row: Int, completion: @escaping (Result<Bool, Error>) -> Void) { 
        didMakeRequestToChangeLike = true
        if isResponseSuccess {
            completion(.success(true))
        } else {
            completion(.failure(TestError.testError))
        }
    }
    
    func getPhoto(at row: Int) -> Photo { 
        return photos[0]
    }
}
