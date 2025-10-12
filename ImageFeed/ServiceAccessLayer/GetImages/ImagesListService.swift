import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let imageListUrl = "https://api.unsplash.com/photos"
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    private func makePhotosRequest(forPage page: Int) -> URLRequest? {
        guard let url = URL(string: "\(imageListUrl)?client_id=\(Constants.accessKey);page=\(page)") else {
            print("[ImagesListService/makePhotosRequest]: Неккоректный URL для API.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private func convert(from photoResults: [PhotoResult]) {
        photoResults.forEach {
            photos.append(Photo(from: $0))
        }
    }
    
    func fetchPhotosNextPage() {
        if self.task != nil {
            print("[ImagesListService/fetchPhotosNextPage]: Страница уже загружается, отмена повторного задания.")
            return
        }
        let pageNumber = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosRequest(forPage: pageNumber) else {
            print("[ImagesListService/fetchPhotosNextPage]: Возникла ошибка при создании запроса.")
            return
        }
        let task = URLSession.shared.objectTask(for: request) {[weak self] (result: Result<[PhotoResult], Error>) in
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
                    userInfo: ["photos": self.photos])
            }
            self.task = nil
        }
        task.resume()
        self.task = task
    }
}
