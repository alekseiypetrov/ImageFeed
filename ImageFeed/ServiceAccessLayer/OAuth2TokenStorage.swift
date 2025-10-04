import UIKit

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let dataStorage = UserDefaults.standard
    private let tokenKey = "accessToken"
    
    private init() {}
    
    var token: String? {
        set {
            if let token = newValue {
                dataStorage.set(token, forKey: tokenKey)
            } else {
                dataStorage.removeObject(forKey: tokenKey)
            }
        }
        get {
            dataStorage.string(forKey: tokenKey)
        }
    }
}
