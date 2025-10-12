import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(from photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        createdAt = ISO8601DateFormatter().date(from: photoResult.createdAt)
        welcomeDescription = photoResult.description
        isLiked = photoResult.likedByUser
        thumbImageURL = photoResult.urls.thumb
        largeImageURL = photoResult.urls.full
    }
}
