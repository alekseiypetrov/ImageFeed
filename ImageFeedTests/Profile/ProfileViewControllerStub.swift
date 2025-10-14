@testable import ImageFeed
import Foundation

final class ProfileViewControllerStub: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var alertResponse: Bool = false
    
    func updateLabels(with profile: ImageFeed.Profile) { }
    
    func updateAvatar(url: URL) { }
    
    func showAlert() {
        if alertResponse {
            presenter?.logoutFromAccount()
        }
    }
}
