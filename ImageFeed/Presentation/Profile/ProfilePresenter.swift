import UIKit
import Kingfisher

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func getProfileImageURL()
    func showAlert(on viewController: UIViewController)
    func logoutFromAccount()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Constants
    
    private enum Constants {
        static let commonImageForAvatar = UIImage(named: "profile_stub")
        static let avatarSize: CGFloat = 70
        static let avatarCornerRadius: CGFloat = 35
        static let placeholderImage: UIImage? = Constants.commonImageForAvatar?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: Constants.avatarSize, 
                                                           weight: .regular, scale: .large))
        static let processor = RoundCornerImageProcessor(cornerRadius: Constants.avatarCornerRadius)
        static let options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .forceRefresh]
    }
    
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
        view?.updateAvatar(
            url: url,
            placeholder: Constants.placeholderImage,
            options: Constants.options)
        { result in
            switch result {
            case .success(let value):
                print("[Profile]: Картинка загружена из: \(value.cacheType)")
                print("[Profile]: Информация об источнике: \(value.source)")
            case .failure(let error):
                print(error)
            }
        }
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
