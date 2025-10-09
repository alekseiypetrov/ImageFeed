import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(for request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error  in
            if let error = error {
                print("\(NetworkError.urlRequestError(error)) При запросе получена ошибка: \(error).")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            if let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode,
               !(200..<300 ~= statusCode) {
                print("\(NetworkError.httpStatusCode(statusCode)) Результат запроса завершился кодом: \(statusCode).")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }
            if let data = data {
                print("Запрос успешно выполнен, данные получены.")
                fulfillCompletionOnTheMainThread(.success(data))
                return
            }
            print("\(NetworkError.urlSessionError) При запросе обнаружена неопознанная ошибка.")
            fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            return
        })
        return task
    }
}
