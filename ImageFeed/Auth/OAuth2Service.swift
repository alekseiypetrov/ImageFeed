import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
}

class SnakeCaseJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenURL = "https://unsplash.com/oauth/token"
    let storage = OAuth2TokenStorage()
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: tokenURL) else {
            print("Ошибка при создании объекта URLComponents по ссылке: \(tokenURL).")
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
            print("Возникла ошибка при сборке URL.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print("POST-запрос успешно собран.")
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Возникла ошибка при создании POST-запроса.")
            return
        }
        let task = URLSession.shared.data(for: request) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("Получена ошибка при выполнении запроса: \(error).")
                completion(.failure(error))
            case .success(let data):
                do {
                    let decoder = SnakeCaseJSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.storage.token = response.accessToken
                    print("Токен успешно получен и сохранен.")
                    completion(.success(response.accessToken))
                } catch {
                    print("Произошла ошибка при декодировании полученной информации: \(error).")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
