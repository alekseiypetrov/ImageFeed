@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var didUpdatedLabels: Bool = false
    var didUpdatedAvatar: Bool = false
    
    func updateLabels(with profile: Profile) {
        didUpdatedLabels = true
    }
    
    func updateAvatar(url: URL) {
        didUpdatedAvatar = true
    }
}
