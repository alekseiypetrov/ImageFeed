import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let avatarSize: CGFloat = 70
        static let avatarCornerRadius: CGFloat = 35
        static let topPadding: CGFloat = 20
        static let leadingPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 8
        static let trailingPadding: CGFloat = -20
        static let buttonSize: CGFloat = 44
        static let usernameSizeOfText: CGFloat = 23
        static let commonSizeOfText: CGFloat = 13
        static let buttonImage = UIImage(named: "logout")
        static let commonImageForAvatar = UIImage(named: "profile_stub")
        static let redColor = UIColor(named: "YP Red")
        static let greyColor = UIColor(named: "YP Grey")
        static let blackColor = UIColor(named: "YP Black")
    }
    
    // MARK: - UI-elements
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: Constants.commonImageForAvatar)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = Constants.redColor
        button.setImage(Constants.buttonImage, for: .normal)
        button.addTarget(self, action: #selector(logoutFromAccount), for: .touchUpInside)
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let username = UILabel()
        username.translatesAutoresizingMaskIntoConstraints = false
        username.text = "Имя не указано"
        username.textColor = .white
        username.font = UIFont.boldSystemFont(ofSize: Constants.usernameSizeOfText)
        return username
    }()
    
    private let userTagLabel: UILabel = {
        let tag = UILabel()
        tag.translatesAutoresizingMaskIntoConstraints = false
        tag.text = "@неизвестный_пользователь"
        tag.textColor = Constants.greyColor
        tag.font = UIFont.systemFont(ofSize: Constants.commonSizeOfText)
        return tag
    }()
    
    private let descriptionLabel: UILabel = {
        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.text = "Профиль не заполнен"
        description.textColor = .white
        description.font = UIFont.systemFont(ofSize: Constants.commonSizeOfText)
        return description
    }()
    
    // MARK: - Properties
    private let profileService = ProfileService.shared
    private let imageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupProfileData()
        setupObserver()
        updateAvatar()
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
    }
    
    private func setupProfileData() {
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
        if !profile.bio.isEmpty {
            descriptionLabel.text = profile.bio
        }
    }
    
    private func updateAvatar() {
        guard let profileImageURL = imageService.avatarURL,
              let url = URL(string: profileImageURL)
        else { return }
        let placeholderImage = Constants.commonImageForAvatar?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: Constants.avatarSize, weight: .regular, scale: .large))
        let processor = RoundCornerImageProcessor(cornerRadius: Constants.avatarCornerRadius)
        avatarImageView.kf.indicatorType = .activity
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [.processor(processor),
                      .scaleFactor(UIScreen.main.scale),
                      .cacheOriginalImage,
                      .forceRefresh
            ]) { result in
                switch result {
                case .success(let value):
                    print("[Profile]: Картинка загружена из: \(value.cacheType)")
                    print("[Profile]: Информация об источнике: \(value.source)")
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func configureUI() {
        view.backgroundColor = Constants.blackColor
        
        [avatarImageView, logoutButton, usernameLabel, descriptionLabel, userTagLabel]
            .forEach {
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingPadding),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topPadding),
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.trailingPadding),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.bottomPadding),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            userTagLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Constants.bottomPadding),
            userTagLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: userTagLabel.bottomAnchor, constant: Constants.bottomPadding),
            descriptionLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor)
        ])
    }
    
    @objc func logoutFromAccount() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default, 
                                      handler: { [weak self] _ in
            guard let self else { return }
            profileLogoutService.logout()
        })
        let noAction = UIAlertAction(title: "Нет", style: .default)
        for action in [yesAction, noAction] {
            alert.addAction(action)
        }
        self.present(alert, animated: true)
    }
}
