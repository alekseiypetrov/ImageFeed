import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let dataStorage = KeychainWrapper.standard
    private let tokenKey = "accessToken"
    
    private init() {}
    
    var token: String? {
        set {
            if let token = newValue {
                let isSuccess = dataStorage.set(token, forKey: tokenKey)
                if isSuccess {
                    print("[OAuth2TokenStorage]: Токен сохранен.")
                } else {
                    print("[OAuth2TokenStorage]: Возникла ошибка при сохранении токена.")
                }
            } else {
                dataStorage.removeObject(forKey: tokenKey)
                print("[OAuth2TokenStorage]: Токен удален.")
            }
        }
        get {
            print("[OAuth2TokenStorage]: Получение токена.")
            return dataStorage.string(forKey: tokenKey)
        }
    }
}
