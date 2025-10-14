import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Static Properties
    
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    
    private let tokenURL = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var lastCode: String?
    private var task: URLSessionTask?
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(code: String, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[OAuth2Service/fetchOAuthToken]: Коды старого и нового запроса совпали. Ничего не делаем.")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        if let task = task {
            print("[OAuth2Service/fetchOAuthToken]: Коды старого и нового запроса не совпали. Отменяем старый запрос и делаем новый.")
            task.cancel()
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service/fetchOAuthToken]: Возникла ошибка при создании POST-запроса.")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("[OAuth2Service/fetchOAuthToken]: \(type(of: error)) Возникла ошибка при получении токена: \(error).")
                completion(.failure(error))
            case .success(let response):
                self.storage.token = response.accessToken
                print("[OAuth2Service/fetchOAuthToken]: Токен успешно получен и сохранен.")
                completion(.success(response.accessToken))
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: tokenURL) else {
            print("[OAuth2Service/makeOAuthTokenRequest]: Ошибка при создании объекта URLComponents по ссылке: \(tokenURL).")
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
            print("[OAuth2Service/makeOAuthTokenRequest]: Возникла ошибка при сборке URL.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
