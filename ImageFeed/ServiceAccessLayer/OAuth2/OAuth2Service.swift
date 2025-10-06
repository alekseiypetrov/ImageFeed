import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
}

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenURL = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var lastCode: String?
    private var task: URLSessionTask?
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: tokenURL) else {
            print("[makeOAuthTokenRequest]: Ошибка при создании объекта URLComponents по ссылке: \(tokenURL).")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else {
            print("[makeOAuthTokenRequest]: Возникла ошибка при сборке URL.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[fetchOAuthToken]: Коды старого и нового запроса совпали. Ничего не делаем.")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        if let task = task {
            print("[fetchOAuthToken]: Коды старого и нового запроса не совпали. Отменяем старый запрос и делаем новый.")
            task.cancel()
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[fetchOAuthToken]: Возникла ошибка при создании POST-запроса.")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = urlSession.data(for: request) {[weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print("[fetchOAuthToken]: Получена ошибка при выполнении запроса: \(error).")
                    completion(.failure(error))
                case .success(let data):
                    do {
                        let decoder = SnakeCaseJSONDecoder()
                        let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        self.storage.token = response.accessToken
                        print(response.accessToken)
                        print("[fetchOAuthToken]: Токен успешно получен и сохранен.")
                        completion(.success(response.accessToken))
                    } catch {
                        print("[fetchOAuthToken]: Произошла ошибка при декодировании данных: \(error).")
                        completion(.failure(error))
                    }
                }
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}
