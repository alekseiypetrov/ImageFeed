import XCTest
import UIKit
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    func testViewControllerCalledViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let sut = ProfilePresenterSpy()
        viewController.configure(sut)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(sut.didCalledViewDidLoad)
    }
    
    func testPresenterCalledUpdateAvatar() {
        // given
        let sut = ProfileViewControllerSpy()
        let presenter = ProfilePresenterStub()
        sut.presenter = presenter
        presenter.view = sut
        
        // when
        presenter.getProfileImageURL()
        
        // then
        XCTAssertTrue(sut.didUpdatedAvatar)
    }
    
    func testPresenterCalledUpdateLabels() {
        // given
        let sut = ProfileViewControllerSpy()
        let presenter = ProfilePresenterStub()
        sut.presenter = presenter
        presenter.view = sut
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(sut.didUpdatedLabels)
    }
    
    func testViewControllerCalledLogoutFromAccount() {
        // given
        let viewController = ProfileViewControllerStub()
        let sut = ProfilePresenterSpy()
        viewController.presenter = sut
        sut.view = viewController
        viewController.alertResponse = true
        
        // when
        viewController.showAlert()
        
        // then
        XCTAssertTrue(sut.didGetATaskToLogout)
    }
    
    func testViewControllerDidNotCalledLogoutFromAccount() {
        // given
        let viewController = ProfileViewControllerStub()
        let sut = ProfilePresenterSpy()
        viewController.presenter = sut
        sut.view = viewController
        viewController.alertResponse = false
        
        // when
        viewController.showAlert()
        
        // then
        XCTAssertFalse(sut.didGetATaskToLogout)
    }
}
