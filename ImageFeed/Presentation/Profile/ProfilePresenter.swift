import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func getProfileImageURL()
    func showAlert(on viewController: UIViewController)
    func logoutFromAccount()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private let profileService = ProfileService.shared
    private let imageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        setupProfileData()
        getProfileImageURL()
    }
    
    func getProfileImageURL() {
        guard let profileImageURL = imageService.avatarURL,
              let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(url: url)
    }
    
    func showAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default,
                                      handler: { [weak self] _ in
            guard let self else { return }
            self.view?.didConfirmLogout()
        })
        let noAction = UIAlertAction(title: "Нет", style: .default)
        for action in [yesAction, noAction] {
            alert.addAction(action)
        }
        viewController.present(alert, animated: true)
    }
    
    func logoutFromAccount() { 
        profileLogoutService.logout()
    }
    
    // MARK: - Private Methods
    
    private func setupProfileData() {
        guard let profile = profileService.profile else { return }
        view?.updateLabels(
            with: Profile(
                username: profile.username,
                name: profile.name.isEmpty ? "Имя не указано" : profile.name,
                loginName: profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName,
                bio: profile.bio.isEmpty ? "Профиль не заполнен" : profile.bio
            )
        )
    }
}
