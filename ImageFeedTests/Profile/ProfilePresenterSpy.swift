@testable import ImageFeed
import UIKit

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var didCalledViewDidLoad: Bool = false
    var didGetATaskToLogout: Bool = false
    var didShowAlert: Bool = false
    
    func viewDidLoad() {
        didCalledViewDidLoad = true
    }
    
    func getProfileImageURL() { }
    
    func showAlert(on viewController: UIViewController) { 
        didShowAlert = true
    }
    
    func logoutFromAccount() {
        didGetATaskToLogout = true
    }
}
