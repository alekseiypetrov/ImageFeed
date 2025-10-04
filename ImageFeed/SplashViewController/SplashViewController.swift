import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
    private let showAuthorizationScreen = "showAuthFlow"
    private let profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            print("Токен есть, переход к галерее.\n\(token)")
            switchToTabBarController()
        } else {
            print("Токена нет, необходимо авторизоваться.")
            performSegue(withIdentifier: showAuthorizationScreen, sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showAuthorizationScreen else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard let navigationController = segue.destination as? UINavigationController,
              let viewController = navigationController.viewControllers.first as? AuthViewController else {
            assertionFailure("Failed to prepare for \(showAuthorizationScreen)")
            return
        }
        viewController.delegate = self
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
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
            case .success:
                self.switchToTabBarController()
            case .failure:
                // TODO: will be made later
                break
            }
        }
    }
}
