import Foundation

struct Response<T> {
    var success: Bool
    var httpCode: Int
    var message: String?
    var errors: [String: [String]]?
    var data: T?
}
