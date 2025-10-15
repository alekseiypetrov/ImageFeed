@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var didCalledUpdateTableViewAnimated: Bool = false
    var didGetSuccessResponse: Bool = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        didCalledUpdateTableViewAnimated = true
    }
    
    func imitatePressOfLikeButton() {
        presenter?.makeRequestToChangeLike(
            at: 0,
            completion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(_):
                    self.didGetSuccessResponse = true
                case .failure(_):
                    self.didGetSuccessResponse = false
                }
            })
    }
}
