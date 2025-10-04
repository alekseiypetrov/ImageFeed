import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
    private let showAuthorizationScreen = "showAuthFlow"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveToken),
                                               name: .didReceiveToken,
                                               object: nil)
    }
    
    @objc private func didReceiveToken() {
        print("SplashVC получил уведомление о новом токене, переключаемся к галерее.")
        switchToTabBarController()
    }
    
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
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
}
