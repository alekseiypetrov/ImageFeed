import Foundation

extension Date {
    static var safe: Date {
        if #available(iOS 15.0, *) {
            return Date.now
        } else {
            return Date()
        }
    }
}
