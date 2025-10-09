import UIKit

final class TabBarController: UITabBarController {
    private let nameOfStoryboard = "Main"
    private let imageListViewIdentifier = "ImagesListViewController"
    private let profileViewIdentifier = "ProfileViewController"
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
}
