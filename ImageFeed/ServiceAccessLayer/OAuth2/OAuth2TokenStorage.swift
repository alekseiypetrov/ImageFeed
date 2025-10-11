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
                    print("Токен сохранен.")
                } else {
                    print("Возникла ошибка при сохранении токена.")
                }
            } else {
                dataStorage.removeObject(forKey: tokenKey)
                print("Токен удален.")
            }
        }
        get {
            print("Получение токена.")
            return dataStorage.string(forKey: tokenKey)
        }
    }
}
