import UIKit

final class OAuth2TokenStorage {
    var token: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "accessToken")
        }
        get {
            return UserDefaults.standard.string(forKey: "accessToken") ?? ""
        }
    }
}
