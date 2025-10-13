import Foundation

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
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "\(profileURL)\(username)") else {
            print("[ProfileImageService/makeProfileImageRequest]: Возникла ошибка при создании URL для получения фотографии профиля.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService/fetchProfileImageURL]: При создании запроса на аватарку пользователя не оказалось токена.")
            completion(.failure(ProfileImageServiceError.tokenMissing))
            return
        }
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService/fetchProfileImageURL]: Возникла ошибка при создании запроса.")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("[ProfileImageService/fetchProfileImageURL]: \(type(of: error)) Возникла ошибка при получении автарки пользователя: \(error).")
                completion(.failure(error))
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.large
                print("[ProfileImageService/fetchProfileImageURL]: URL аватарки успешно получен.")
                completion(.success(userResult.profileImage.large))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": userResult.profileImage.small])
            }
        }
        self.task = task
        task.resume()
    }
}
