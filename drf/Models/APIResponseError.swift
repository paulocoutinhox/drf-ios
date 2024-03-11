import Foundation

struct APIResponseError: Decodable {
    let detail: String?
    let code: String?
}
