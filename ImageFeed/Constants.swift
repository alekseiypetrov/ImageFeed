import UIKit

enum Constants {
    static let accessKey = "CE-74FVG4hTRABZjSbxlHcwqWWHHv9q9Gm8uwqzuzqU"
    static let secretKey = "nsG7KNT3TOgXqcYAUV_F2ExB_pdsTJg4gM-bmtvXCNM"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
}

extension Notification.Name {
    static let didReceiveToken = Notification.Name("didReceiveToken")
}

class SnakeCaseJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
