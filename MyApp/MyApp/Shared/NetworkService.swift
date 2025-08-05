import Foundation
import Dependencies

struct AuthService {
    var logout: (_ user: User) async throws -> User
    var login: (_ email: String, _ password: String) async throws -> User
    var register: (_ email: String, _ password: String) async throws -> User
    var forgotPassword: (_ email: String) async throws -> String
    var changePassword: (_ email: String, _ password: String, _ oldPassword: String) async throws -> User
    var deleteAccount: (_ email: String, _ password: String, _ selectedReasons: [String]) async throws -> User
}

struct NetworkService {
    
    func logout(user: User) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard !user.email.isEmpty else {
            throw ErrorEquatable(message: "network.error.logoutIncorrect")
        }
        return user
    }
    
    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard email == "test@example.com", password == "123456" else {
            throw ErrorEquatable(message: "network.error.invalidCredentials")
        }
        let token = Token(value: "dummy-auth-token-for-\(email)", expiresAt: Date().addingTimeInterval(3600)) // Hết hạn sau 1 giờ
        return User(id: UUID(), name: "Test User", email: email, token: token)
    }
    
    func register(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard email != "test@example.com", !password.isEmpty else {
            throw ErrorEquatable(message: "network.error.emailExists")
        }
        let token = Token(value: "dummy-auth-token-for-new-user-\(email)", expiresAt: Date().addingTimeInterval(3600)) // Hết hạn sau 1 giờ
        return User(id: UUID(), name: "Test New User", email: email, token: token)
        
    }
    
    func forgotPassword(email: String) async throws -> String {
        try await Task.sleep(for: .seconds(1))
        guard email == "test@example.com" else {
            throw ErrorEquatable(message: "network.error.emailNotFound")
        }
        return NSLocalizedString("network.success.forgotPassword", comment: "Forgot password success message")
        
    }
    
    func changePassword(email: String, password: String, oldPassword: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard !email.isEmpty, oldPassword == "123456" else {
            throw ErrorEquatable(message: "network.error.incorrectOldPassword")
        }
        let token = Token(value: "new-dummy-auth-token-after-password-change", expiresAt: Date().addingTimeInterval(3600)) // Hết hạn sau 1 giờ
        return User(id: UUID(), name: "Test User", email: email, token: token)
    }
    
    func deleteAccount(email: String, password: String, selectedReasons: [String]) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard !email.isEmpty, password == "123456" else {
            throw ErrorEquatable(message: "network.error.incorrectPassword")
        }
        let token = Token(value: "invalidated-token-after-delete", expiresAt: Date()) // Hết hạn ngay lập tức
        return User(id: UUID(), name: "Test User", email: email, token: token)
    }
}
