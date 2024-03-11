import Foundation

class APIClient {
    static let shared = APIClient()

    private var baseURL = URL(string: "http://localhost:8000/api/")
    private var authToken: String?

    func setBaseURL(_ url: URL) {
        baseURL = url
    }

    func setAuthToken(_ token: String?) {
        authToken = token
    }

    func request<T: Decodable>(endpoint: String, method: String, parameters: [String: Any]? = nil, type: ResponseType, completion: @escaping (Result<Response<T>, Error>) -> Void) {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            let error = NSError(domain: "APIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.uppercased()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let authToken = authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                completion(.failure(error))
                return
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, let responseData = data else {
                let error = NSError(domain: "APIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error or no data"])
                completion(.failure(error))
                return
            }

            let decoder = JSONDecoder()

            if (200 ... 299).contains(httpResponse.statusCode) {
                do {
                    let apiResponse: Response<T>
                    switch type {
                    case .list:
                        let decodedList = try decoder.decode(ResponseList<T>.self, from: responseData)
                        apiResponse = Response(success: true, httpCode: httpResponse.statusCode, message: "success", errors: nil, data: decodedList.results)
                    case .single:
                        let resultData = try decoder.decode(T.self, from: responseData)
                        apiResponse = Response(success: true, httpCode: httpResponse.statusCode, message: "success", errors: nil, data: resultData)
                    }
                    completion(.success(apiResponse))
                } catch {
                    completion(.failure(error))
                }
            } else {
                var apiResponse: Response<T> = Response(success: false, httpCode: httpResponse.statusCode, message: "error", errors: nil, data: nil)

                switch httpResponse.statusCode {
                case 400:
                    do {
                        let validationErrors = try decoder.decode([String: [String]].self, from: responseData)
                        apiResponse.errors = validationErrors
                        completion(.success(apiResponse))
                    } catch {
                        completion(.failure(error))
                    }
                case 401 ... 499:
                    do {
                        let errorDetail = try decoder.decode(ResponseError.self, from: responseData)
                        apiResponse.message = errorDetail.code ?? "error"

                        if let errorDetail = errorDetail.detail {
                            apiResponse.errors = ["error": [errorDetail]]
                        }

                        completion(.success(apiResponse))
                    } catch {
                        completion(.failure(error))
                    }
                case 500 ... 599:
                    apiResponse.message = "internal-error"
                    completion(.success(apiResponse))
                default:
                    completion(.success(apiResponse))
                }
            }
        }.resume()
    }
}
