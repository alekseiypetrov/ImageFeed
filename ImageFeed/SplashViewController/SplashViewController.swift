import UIKit

final class SplashViewController: UIViewController {
    private let nameOfStoryboard = "Main"
    private let authViewIdentifier = "AuthViewController"
    private let tabBarViewIdentifier = "TabBarViewController"
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor(named: "YP Black")
        let image = UIImage(named: "Vector")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.token {
            print("Токен есть, переход к галерее.\n\(token)")
            fetchProfile(token: token)
        } else {
            print("Токена нет, необходимо авторизоваться.")
            guard let authViewController = UIStoryboard(name: nameOfStoryboard, bundle: .main).instantiateViewController(withIdentifier: authViewIdentifier) as? AuthViewController else {
                print("Не удалось найти AuthViewController по идентификатору")
                return
            }
            authViewController.delegate = self
//            authViewController.modalPresentationStyle = .fullScreen
            let navigationController = UINavigationController()
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.viewControllers = [authViewController]
            self.present(navigationController, animated: true, completion: nil)
//            self.present(authViewController, animated: true, completion: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: nameOfStoryboard, bundle: .main).instantiateViewController(withIdentifier: tabBarViewIdentifier)
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthentificate(_ vc: AuthViewController) {
        guard let token = storage.token else {
            return
        }
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchProfile(token: token)
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageURL(username: profile.username) {_ in }
                self.switchToTabBarController()
            case .failure(let error):
                print("[SplashScreen/fetchProfile]: Произошла ошибка при загрузке профиля: \(error).")
                break
            }
        }
    }
}
