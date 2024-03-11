import Foundation

struct ResponseList<T: Decodable>: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: T
}
