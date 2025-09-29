import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    let storage = OAuth2TokenStorage()
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com") else {
            return nil
        }
        urlComponents.path = "/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            return
        }
        let task = URLSession.shared.data(for: request) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("Получена ошибка")
                completion(.failure(error))
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    print("Токен успешно получен")
                    self.storage.token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    print("Произошла ошибка при декодировании полученной информации: \(error)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
