import Foundation

struct User: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let email: String
}