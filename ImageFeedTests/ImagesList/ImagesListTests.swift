import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    func testViewControllerCalledMakeRequestForAnotherPage() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let sut = ImagesListPresenterSpy()
        viewController.configure(sut)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(sut.didMakeRequestForAnotherPage)
    }
    
    func testPresenterCalledUpdateTableViewAnimated() {
        // given
        let presenter = ImagesListPresenterStub()
        let sut = ImagesListViewControllerSpy()
        sut.presenter = presenter
        presenter.view = sut
        presenter.isEqualOldCountAndNewCount = true
        
        // when
        presenter.handlePhotosUpdatedNotification()
        
        // then
        XCTAssertTrue(sut.didCalledUpdateTableViewAnimated)
    }
    
    func testPresenterDidNotCalledUpdateTableViewAnimated() {
        // given
        let presenter = ImagesListPresenterStub()
        let sut = ImagesListViewControllerSpy()
        sut.presenter = presenter
        presenter.view = sut
        presenter.isEqualOldCountAndNewCount = false
        
        // when
        presenter.handlePhotosUpdatedNotification()
        
        // then
        XCTAssertFalse(sut.didCalledUpdateTableViewAnimated)
    }
    
    func testViewControllerCalledLikeRequestAndGetSuccessResponse() {
        // given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.isResponseSuccess = true
        
        // when
        viewController.imitatePressOfLikeButton()
        
        // then
        XCTAssertTrue(presenter.didMakeRequestToChangeLike)
        XCTAssertTrue(viewController.didGetSuccessResponse)
    }
    
    func testViewControllerCalledLikeRequestAndGetError() {
        // given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.isResponseSuccess = false
        
        // when
        viewController.imitatePressOfLikeButton()
        
        // then
        XCTAssertTrue(presenter.didMakeRequestToChangeLike)
        XCTAssertFalse(viewController.didGetSuccessResponse)
    }
    
    func testGetPhoto() {
        // given
        let presenter = ImagesListPresenterStub()
        let sut = ImagesListViewControllerSpy()
        sut.presenter = presenter
        presenter.view = sut
        presenter.photos = [
            Photo(id: "1", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
            Photo(id: "2", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
            Photo(id: "3", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
            Photo(id: "4", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
            Photo(id: "5", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
        ]
        
        // when
        let photo = sut.presenter?.getPhoto(at: 3)
        
        // then
        XCTAssertNotNil(photo)
        XCTAssertTrue(type(of: photo!) == Photo.self)
    }
    
    func testGetNumberOfUploadPhotos() {
        // given
        let presenter = ImagesListPresenterStub()
        let sut = ImagesListViewControllerSpy()
        sut.presenter = presenter
        presenter.view = sut
        presenter.photos = [
            Photo(id: "1", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
            Photo(id: "2", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
            Photo(id: "3", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
            Photo(id: "4", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
            Photo(id: "5", size: CGSize(width: 1, height: 1), createdAt: Date.safe, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: true),
        ]
        
        // when
        let number = sut.presenter?.photosCount
        
        // then
        XCTAssertEqual(number, presenter.photos.count)
    }
}
