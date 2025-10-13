import Foundation

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = SnakeCaseJSONDecoder()
        let task = data(for: request) {result in
            switch result {
            case .failure(let error):
                print("[URLSession/objectTask]: Запрос данных типа \(T.self) закончился ошибкой: \(error)")
                completion(.failure(error))
            case .success(let data):
                do {
                    let result = try decoder.decode(T.self, from: data)
                    print("[URLSession/objectTask]: Процесс декодирования информации типа \(T.self) прошел успешно.")
                    completion(.success(result))
                } catch {
                    if let decodingError = error as? DecodingError {
                        print("[URLSession/objectTask]: Ошибка декодирования: \(decodingError), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    } else {
                        print("[URLSession/objectTask]: Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}
