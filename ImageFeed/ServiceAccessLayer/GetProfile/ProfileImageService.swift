import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage
}

enum ProfileImageServiceError: Error {
    case invalidRequest
    case tokenMissing
    case decodingError
}

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}
    private(set) var avatarURL: String?
    private let profileURL = "https://api.unsplash.com/users/"
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[fetchProfileImageURL]: При создании запроса на аватарку пользователя не оказалось токена.")
            completion(.failure(ProfileImageServiceError.tokenMissing))
            return
        }
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[fetchProfileImageURL]: Возникла ошибка при создании запроса.")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        let task = urlSession.data(for: request) {[weak self] result in
            switch result {
            case .failure(let error):
                print("[fetchProfileImageURL]: Возникла ошибка при выполнении запроса автарки пользователя - \(error).")
                completion(.failure(error))
            case .success(let data):
                do {
                    guard let self = self else { return }
                    let decoder = SnakeCaseJSONDecoder()
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    self.avatarURL = userResult.profileImage.small
                    print("[fetchProfileImageURL]: URL аватарки успешно получен.")
                    completion(.success(userResult.profileImage.small))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self, 
                        userInfo: ["URL": userResult.profileImage.small])
                } catch {
                    print("[fetchProfileImageURL]: Возникла ошибка при декодировании данных: \(error).")
                    completion(.failure(ProfileImageServiceError.decodingError))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "\(profileURL)\(username)") else {
            print("[makeProfileImageRequest]: Возникла ошибка при создании URL для получения фотографии профиля.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
