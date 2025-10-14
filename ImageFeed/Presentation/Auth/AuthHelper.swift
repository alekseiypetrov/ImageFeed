import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            print("[AuthHelper/authRequest]: Возникла ошибка при сборке URL.")
            return nil
        }
        return URLRequest(url: url)
    }
    
    private func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            print("[AuthHelper/authURL]: Ошибка при создании объекта URLComponents по ссылке: \(configuration.authURLString).")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            print("[WebViewPresenter/code]: Код аутентификации успешно получен.")
            return codeItem.value
        } else {
            print("[WebViewPresenter/code]: Возникла ошибка при получении кода для аутентификации.")
            return nil
        }
    }
}
