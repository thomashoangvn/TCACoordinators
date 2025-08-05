import Foundation

struct Token: Equatable, Hashable, Codable {
    let value: String
    let expiresAt: Date
}

struct User: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    let name: String
    let email: String
    let token: Token
}