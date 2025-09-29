import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let showAuthorizationScreen = "showAuthFlow"
    private let showGalleryScreen = "showGallaryFlow"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil {
            switchToTabBarController()
        } else {
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
