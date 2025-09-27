import UIKit

enum Colors {
    static let leftBackgroundColorOfImageView = UIColor(red: 174.0 / 255.0, green: 175.0 / 255.0, blue: 180.0 / 255.0, alpha: 1.0)
    static let rightBackgroundColorOfImageView = UIColor(red: 174.0 / 255.0, green: 175.0 / 255.0, blue: 180.0 / 255.0, alpha: 0.3)
    static let backgroundColor = UIColor(red: 26.0 / 255.0, green: 27.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0)
    static let buttonLogoutOrLikedTintColor = UIColor(red: 245.0 / 255.0, green: 107.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
    static let tagLabelTintColor = UIColor(red: 174.0 / 255.0, green: 175.0 / 255.0, blue: 180.0 / 255.0, alpha: 1.0)
}

enum Constants {
    static let accessKey = "CE-74FVG4hTRABZjSbxlHcwqWWHHv9q9Gm8uwqzuzqU"
    static let secretKey = "nsG7KNT3TOgXqcYAUV_F2ExB_pdsTJg4gM-bmtvXCNM"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
}
