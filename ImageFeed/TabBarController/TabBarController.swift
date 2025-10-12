import UIKit

final class TabBarController: UITabBarController {
    private let nameOfStoryboard = "Main"
    private let imageListViewIdentifier = "ImagesListViewController"
    private let profileViewIdentifier = "ProfileViewController"
    private var logoutFromAccountObserver: NSObjectProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupObserver()
        
        let storyboard = UIStoryboard(name: nameOfStoryboard, bundle: .main)
                
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: imageListViewIdentifier
        )
                
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "YP Black")
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(
            forName: ProfileLogoutService.didLogoutFromAccount,
            object: nil,
            queue: .main,
            using: {[weak self] _ in
                guard let self else { return }
                self.deleteTokenAndRestart()
            })
    }
    
    private func deleteTokenAndRestart() {
        OAuth2TokenStorage.shared.token = nil
        guard let window = UIApplication.shared.windows.first else { return }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        print("[TabBar]: Splash создан, передача управления.")
        window.makeKeyAndVisible()
    }
}
