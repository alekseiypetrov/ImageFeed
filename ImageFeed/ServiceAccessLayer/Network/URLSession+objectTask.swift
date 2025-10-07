import Foundation

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = SnakeCaseJSONDecoder()
        let task = data(for: request) {result in
            switch result {
            case .failure(let error):
                print("Запрос данных типа \(T.self) закончился ошибкой: \(error)")
                completion(.failure(error))
            case .success(let data):
                do {
                    let result = try decoder.decode(T.self, from: data)
                    print("Процесс декодирования информации типа \(T.self) прошел успешно.")
                    completion(.success(result))
                } catch {
                    if let decodingError = error as? DecodingError {
                        print("Ошибка декодирования: \(decodingError), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    } else {
                        print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}
