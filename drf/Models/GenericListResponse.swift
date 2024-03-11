import Foundation

struct GenericListResponse<T: Decodable>: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: T
}
