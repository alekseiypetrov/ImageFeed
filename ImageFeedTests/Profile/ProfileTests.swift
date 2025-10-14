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
    
    func testPresenterShowAlert() {
        // given
        let viewController = ProfileViewController()
        let sut = ProfilePresenterSpy()
        viewController.configure(sut)
        
        // when
        viewController.logoutButtonPressed()
        
        // then
        XCTAssertTrue(sut.didShowAlert)
    }
    
    func testPositiveResponseFromAlert() {
        // given
        let sut = ProfileViewControllerSpy()
        let presenter = ProfilePresenterStub()
        sut.presenter = presenter
        presenter.view = sut
        presenter.alertResponse = true
        
        // when
        presenter.showAlert(on: UIViewController())
        
        // then
        XCTAssertTrue(sut.didGetResponseFromAlert)
    }
    
    func testNegativeResponseFromAlert() {
        // given
        let sut = ProfileViewControllerSpy()
        let presenter = ProfilePresenterStub()
        sut.presenter = presenter
        presenter.view = sut
        presenter.alertResponse = false
        
        // when
        presenter.showAlert(on: UIViewController())
        
        // then
        XCTAssertFalse(sut.didGetResponseFromAlert)
    }
    
    func testPresenterGetATaskToLogout() {
        // given
        let viewController = ProfileViewController()
        let sut = ProfilePresenterSpy()
        viewController.configure(sut)
        
        // when
        viewController.didConfirmLogout()
        
        // then
        XCTAssertTrue(sut.didGetATaskToLogout)
    }
}
