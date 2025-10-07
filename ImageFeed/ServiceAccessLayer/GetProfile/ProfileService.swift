import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = "\(profileResult.firstName) \(profileResult.lastName)".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(username)"
        self.bio = profileResult.bio
    }
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
}

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let profileURL = URL(string: "https://api.unsplash.com/me")
    private(set) var profile: Profile?
    
    private init() {}
    
    private func makeProfileRequest(_ token: String) -> URLRequest? {
        guard let url = profileURL else {
            print("Неккоректный URL для API.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        guard let request = makeProfileRequest(token) else {
            print("[fetchProfile]: Ошибка при создании запроса.")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print("[fetchProfile]: \(type(of: error)) Возникла ошибка при получении данных по профилю: \(error)")
                    completion(.failure(error))
                case .success(let profileResult):
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    print("[fetchProfile]: Данные о профиле получены.")
                    completion(.success(profile))
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
}
