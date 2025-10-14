@testable import ImageFeed
import UIKit

final class ProfilePresenterStub: ProfilePresenterProtocol {
    weak var view: ImageFeed.ProfileViewControllerProtocol?
    var alertResponse: Bool = false
    var profileStub = Profile(username: "user", name: "name", loginName: "login", bio: "bio")
    var urlStub: URL = Constants.defaultBaseURL
    
    func viewDidLoad() {
        view?.updateLabels(with: profileStub)
    }
    
    func getProfileImageURL() {
        view?.updateAvatar(url: urlStub)
    }
    
    func showAlert(on viewController: UIViewController) { 
        if alertResponse {
            view?.didConfirmLogout()
        }
    }
    
    func logoutFromAccount() { }
}
