import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    
    // MARK: - Static Properties
    
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let profileURL = URL(string: "https://api.unsplash.com/me")
    private(set) var profile: Profile?
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        guard let request = makeProfileRequest(token) else {
            print("[ProfileService/fetchProfile]: Ошибка при создании запроса.")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .failure(let error):
                    print("[ProfileService/fetchProfile]: \(type(of: error)) Возникла ошибка при получении данных по профилю: \(error)")
                    completion(.failure(error))
                case .success(let profileResult):
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    print("[ProfileService/fetchProfile]: Данные о профиле получены.")
                    completion(.success(profile))
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeProfileRequest(_ token: String) -> URLRequest? {
        guard let url = profileURL else {
            print("[ProfileService/makeProfileRequest]: Неккоректный URL для API.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
