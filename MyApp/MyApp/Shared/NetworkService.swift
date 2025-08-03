import Foundation

protocol AuthServiceProtocol {
    func logout(user: User) async throws -> User
    func login(email: String, password: String) async throws -> User
    func register(email: String, password: String) async throws -> User
    func forgotPassword(email: String) async throws -> String
    func changePassword(email: String, password: String, oldPassword: String) async throws -> User
    func deleteAccount(email: String, password: String, selectedReasons: [String]) async throws -> User
}

final class NetworkService: AuthServiceProtocol {
    static let shared = NetworkService()
    
    func logout(user: User) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard !user.email.isEmpty else {
            throw ErrorEquatable(message: "Logout is incorrect. Please try again.")
        }
        return user
    }
    
    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard email == "test@example.com", password == "123456" else {
            throw ErrorEquatable(message: "The email or password you entered is incorrect. Please try again.")
        }
        let token = Token(value: "dummy-auth-token-for-\(email)", expiresAt: Date().addingTimeInterval(3600)) // Hết hạn sau 1 giờ
        return User(id: UUID(), name: "Test User", email: email, token: token)
    }
    
    func register(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard email != "test@example.com", !password.isEmpty else {
            throw ErrorEquatable(message: "An account with this email already exists.")
        }
        let token = Token(value: "dummy-auth-token-for-new-user-\(email)", expiresAt: Date().addingTimeInterval(3600)) // Hết hạn sau 1 giờ
        return User(id: UUID(), name: "Test New User", email: email, token: token)
        
    }
    
    func forgotPassword(email: String) async throws -> String {
        try await Task.sleep(for: .seconds(1))
        guard email == "test@example.com" else {
            throw ErrorEquatable(message: "We couldn't find an account associated with that email address.")
        }
        return "An email has been sent to reset your password."
        
    }
    
    func changePassword(email: String, password: String, oldPassword: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard !email.isEmpty, oldPassword == "123456" else {
            throw ErrorEquatable(message: "The old password you entered is incorrect. Please try again.")
        }
        let token = Token(value: "new-dummy-auth-token-after-password-change", expiresAt: Date().addingTimeInterval(3600)) // Hết hạn sau 1 giờ
        return User(id: UUID(), name: "Test User", email: email, token: token)
    }
    
    func deleteAccount(email: String, password: String, selectedReasons: [String]) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard !email.isEmpty, password == "123456" else {
            throw ErrorEquatable(message: "The password you entered is incorrect. Please try again.")
        }
        let token = Token(value: "invalidated-token-after-delete", expiresAt: Date()) // Hết hạn ngay lập tức
        return User(id: UUID(), name: "Test User", email: email, token: token)
    }
}
