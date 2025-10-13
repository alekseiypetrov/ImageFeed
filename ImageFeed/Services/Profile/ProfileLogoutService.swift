import Foundation
import WebKit
import Kingfisher

final class ProfileLogoutService {
    static let didLogoutFromAccount = Notification.Name(rawValue: "LogoutFromAccountWasMade")
    static let shared = ProfileLogoutService()
    private init() { }
    
    func logout() {
        UIBlockingProgressHUD.show()
        cleanCookies()
        cleanCache()
        UIBlockingProgressHUD.dismiss()
    }
    
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
    
