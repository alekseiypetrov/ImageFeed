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
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: Constants.commonImageForAvatar)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingPadding),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topPadding)
        ])
            
        return imageView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = Constants.redColor
        button.setImage(Constants.buttonImage, for: .normal)
        view.addSubview(button)
        
        logoutButton.addTarget(self, action: #selector(logoutFromAccount), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.trailingPadding),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
        
        return button
    }()
    
    private lazy var usernameLabel: UILabel = {
        let username = UILabel()
        username.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(username)
        username.text = "Имя не указано"
        username.textColor = .white
        username.font = UIFont.boldSystemFont(ofSize: Constants.usernameSizeOfText)
        
        NSLayoutConstraint.activate([
            username.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.bottomPadding),
            username.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor)
        ])
        return username
    }()
    
    private lazy var userTagLabel: UILabel = {
        let tag = UILabel()
        tag.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tag)
        tag.text = "@неизвестный_пользователь"
        tag.textColor = Constants.greyColor
        tag.font = UIFont.systemFont(ofSize: Constants.commonSizeOfText)
        
        NSLayoutConstraint.activate([
            tag.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Constants.bottomPadding),
            tag.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor)
        ])
        return tag
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(description)
        description.text = "Профиль не заполнен"
        description.textColor = .white
        description.font = UIFont.systemFont(ofSize: Constants.commonSizeOfText)
        
        NSLayoutConstraint.activate([
            description.topAnchor.constraint(equalTo: userTagLabel.bottomAnchor, constant: Constants.bottomPadding),
            description.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor)
        ])
        return description
    }()
    
    // MARK: - Properties
    private let profileService = ProfileService.shared
    private let imageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupProfileData()
        setupObserver()
        updateAvatar()
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) {[weak self] _ in
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
        if let bio = profile.bio,
            !bio.isEmpty {
            descriptionLabel.text = bio
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
                    print("Картинка загружена из: \(value.cacheType)")
                    print("Информация об источнике: \(value.source)")
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func configureView() {
        view.backgroundColor = Constants.blackColor
    }
    
    @objc func logoutFromAccount() {
    }
}
