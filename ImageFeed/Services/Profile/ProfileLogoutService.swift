import Foundation
import WebKit
import Kingfisher

final class ProfileLogoutService {
    
    // MARK: - Static Properties
    
    static let didLogoutFromAccount = Notification.Name(rawValue: "LogoutFromAccountWasMade")
    static let shared = ProfileLogoutService()
    
    // MARK: - Initializer
    
    private init() { }
    
    // MARK: - Public Methods
    
    func logout() {
        UIBlockingProgressHUD.show()
        cleanCookies()
        cleanCache()
        UIBlockingProgressHUD.dismiss()
    }
    
    // MARK: - Private Methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(
                        ofTypes: record.dataTypes,
                        for: [record], completionHandler: {})
                }
            }
        print("[ProfileLogoutService/cleanCookies]: Куки очищены.")
    }
    
    private func cleanCache() {
        ImageCache.default.clearCache() {
            print("[ProfileLogoutService/cleanCache]: Кэш очищен.")
            NotificationCenter.default.post(
                name: ProfileLogoutService.didLogoutFromAccount,
                object: self)
        }
    }
}
    
