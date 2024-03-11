import Foundation

struct ResponseError: Decodable {
    let detail: String?
    let code: String?
}
