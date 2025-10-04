import UIKit

final class ProfileViewController: UIViewController {
    
    private weak var avatarImageView: UIImageView!
    private weak var logoutButton: UIButton!
    private weak var usernameLabel: UILabel!
    private weak var userTagLabel: UILabel!
    private weak var descriptionLabel: UILabel!
    
    private let dataStorage = OAuth2TokenStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIElements()
    }
    
    private func configureUIElements() {
        view.backgroundColor = UIColor(named: "YP Black")
        configureProfileImage()
        configureButton()
        guard let token = dataStorage.token else {
            print("Нет токена.")
            configureLabels(with: Profile(from: ProfileResult(username: "", firstName: "", lastName: "", bio: nil)))
            return
        }
        ProfileService.shared.fetchProfile(token) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.configureLabels(with: profile)
            case .failure(let error):
                print("Ошибка при получении данных о профиле: \(error).")
                break
            }
        }
//        configureLabels()
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
    
    private func configureLabels(with profile: Profile) {
        let username = UILabel()
        let tag = UILabel()
        let description = UILabel()
        
        username.translatesAutoresizingMaskIntoConstraints = false
        tag.translatesAutoresizingMaskIntoConstraints = false
        description.translatesAutoresizingMaskIntoConstraints = false
        for label in [username, tag, description] {
            self.view.addSubview(label)
        }
        
        username.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        tag.text = profile.loginName.isEmpty ?"@неизвестный_пользователь" : profile.loginName
        if let bio = profile.bio,
           !bio.isEmpty {
            description.text = bio
        } else {
            description.text = "Профиль не заполнен"
        }
        
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
