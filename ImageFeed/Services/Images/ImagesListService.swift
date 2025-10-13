import UIKit

enum ImagesListServiceError: Error {
    case indexDoesNotExist
}

final class ImagesListService {
    private struct LikeResult: Codable {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private init() {}
    private let imageListUrl = "https://api.unsplash.com/photos"
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let storage = OAuth2TokenStorage.shared
    
    private func makePhotosRequest(forPage page: Int) -> URLRequest? {
        guard let url = URL(string: "\(imageListUrl)?client_id=\(Constants.accessKey)&page=\(page)") else {
            print("[ImagesListService/makePhotosRequest]: Некорректный URL для API.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = storage.token else {
            print("[ImagesListService/makePhotosRequest]: Нет токена, выполняется публичный запрос.")
            return request
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("[ImagesListService/makePhotosRequest]: Есть токен, выполняется авторизованный запрос.")
        return request
    }
    
    private func convert(from photoResults: [PhotoResult]) {
        photoResults.forEach {
            photos.append(Photo(from: $0))
        }
    }
    
    func fetchPhotosNextPage() {
        guard task == nil else {
            print("[ImagesListService/fetchPhotosNextPage]: Страница уже загружается, отмена повторного задания.")
            return
        }
        
        let pageNumber = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosRequest(forPage: pageNumber) else {
            print("[ImagesListService/fetchPhotosNextPage]: Возникла ошибка при создании запроса.")
            return
        }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("[ImagesListService/fetchPhotosNextPage]: Возникла ошибка при загрузке страницы №\(pageNumber): \(error).")
            case .success(let photoResults):
                print("[ImagesListService/fetchPhotosNextPage]: Страница №\(pageNumber) успешно загружена.")
                self.convert(from: photoResults)
                self.lastLoadedPage = pageNumber
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photos": self.photos]
                )
            }
            self.task = nil
        }
        task.resume()
        self.task = task
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(imageListUrl)/\(photoId)/like") else {
            print("[ImagesListService/changeLike]: Неккоректный URL для API.")
            return
        }
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService/changeLike]: Нет токена.")
            return
        }
        var request = URLRequest(url: url)
        let httpMethod = isLike ? "POST" : "DELETE"
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("[ImagesListService/changeLike]: Возникла ошибка при выполнении \(httpMethod)-запроса: \(error).")
                completion(.failure(error))
            case .success:
                print("[ImagesListService/changeLike]: \(httpMethod)-запрос выполнен успешно.")
                if let index = self.photos.firstIndex(where: { $0.id == photoId} ) {
                    self.photos[index].isLiked = isLike
                    completion(.success(()))
                } else {
                    completion(.failure(ImagesListServiceError.indexDoesNotExist))
                }
            }
        }
        task.resume()
    }
}
