import UIKit

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
                print("[URLSession/data]: \(NetworkError.urlRequestError(error)) При запросе получена ошибка: \(error).")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            if let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode,
               !(200..<300 ~= statusCode) {
                print("[URLSession/data]: \(NetworkError.httpStatusCode(statusCode)) Результат запроса завершился кодом: \(statusCode).")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }
            if let data = data {
                print("[URLSession/data]: Запрос успешно выполнен, данные получены.")
                fulfillCompletionOnTheMainThread(.success(data))
                return
            }
            print("[URLSession/data]: \(NetworkError.urlSessionError) При запросе обнаружена неопознанная ошибка.")
            fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            return
        })
        return task
    }
}
