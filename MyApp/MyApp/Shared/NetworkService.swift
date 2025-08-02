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
        return User(id: UUID(), name: "Test User", email: email)
    }
    
    func register(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard email != "test@example.com", !password.isEmpty else {
            throw ErrorEquatable(message: "An account with this email already exists.")
        }
        return User(id: UUID(), name: "Test New User", email: email)
        
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
        return User(id: UUID(), name: "Test User", email: email)
    }
    
    func deleteAccount(email: String, password: String, selectedReasons: [String]) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        guard !email.isEmpty, password == "123456" else {
            throw ErrorEquatable(message: "The password you entered is incorrect. Please try again.")
        }
        return User(id: UUID(), name: "Test User", email: email)
    }
}
