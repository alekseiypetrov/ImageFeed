import UIKit

final class ProfileViewController: UIViewController {
    
    private weak var avatarImageView: UIImageView!
    private weak var logoutButton: UIButton!
    private weak var usernameLabel: UILabel!
    private weak var userTagLabel: UILabel!
    private weak var descriptionLabel: UILabel!
    
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIElements()
        guard let profile = profileService.profile else { return }
        updateLabels(with: profile)
    }
    
    private func updateLabels(with profile: Profile) {
        if !profile.name.isEmpty {
            usernameLabel.text = profile.name
        }
        if !profile.loginName.isEmpty {
            userTagLabel.text = profile.loginName
        }
        if let bio = profile.bio,
            !bio.isEmpty {
            descriptionLabel.text = bio
        }
    }
    
    private func configureUIElements() {
        view.backgroundColor = UIColor(named: "YP Black")
        configureProfileImage()
        configureLabels()
        configureButton()
    }
    
    private func configureProfileImage() {
        let image = UIImage(named: "profile_stub")
        let imageView = UIImageView(image: image)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
            
        self.avatarImageView = imageView
    }
    
    private func configureLabels() {
        let username = UILabel()
        let tag = UILabel()
        let description = UILabel()
        
        username.translatesAutoresizingMaskIntoConstraints = false
        tag.translatesAutoresizingMaskIntoConstraints = false
        description.translatesAutoresizingMaskIntoConstraints = false
        for label in [username, tag, description] {
            self.view.addSubview(label)
        }
        
        username.text = "Имя не указано"
        tag.text = "@неизвестный_пользователь"
        description.text = "Профиль не заполнен"
        
        for label in [username, description] {
            label.textColor = .white
        }
        tag.textColor = UIColor(named: "YP Grey")
        username.font = UIFont.boldSystemFont(ofSize: 23)
        tag.font = UIFont.systemFont(ofSize: 13)
        description.font = UIFont.systemFont(ofSize: 13)
        
        NSLayoutConstraint.activate([
            username.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            tag.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 8),
            description.topAnchor.constraint(equalTo: tag.bottomAnchor, constant: 8),
            username.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            tag.leadingAnchor.constraint(equalTo: username.leadingAnchor),
            description.leadingAnchor.constraint(equalTo: username.leadingAnchor)
        ])
        
        self.usernameLabel = username
        self.userTagLabel = tag
        self.descriptionLabel = description
    }
    
    private func configureButton() {
        let image = UIImage(named: "logout")
        let button = UIButton.systemButton(with: image!, target: self, action: #selector(logoutFromAccount))
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.tintColor = UIColor(named: "YP Red")
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
        
        self.logoutButton = button
    }
    
    @objc func logoutFromAccount(_ sender: Any) {
    }
}
