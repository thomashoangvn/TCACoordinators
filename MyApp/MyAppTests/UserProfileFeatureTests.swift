//
//  UserProfileFeatureTests.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/3/25.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import MyApp


@MainActor
struct UserProfileFeatureTests {
    // A mock user for use in tests.
    private var user = User(id: UUID(0), name: "Thomas", email: "thomas@example.com")
    
    // A mock service for testing that conforms to AuthServiceProtocol
    private struct MockAuthService: AuthServiceProtocol {
        var logoutImpl: ((User) async throws -> User)?
        
        func logout(user: User) async throws -> User {
            guard let logoutImpl else {
                fatalError("logout(user:) is not implemented for this test")
            }
            return try await logoutImpl(user)
        }
        
        // Other methods are not needed for these tests, so they can be left as fatalError.
        func login(email: String, password: String) async throws -> User { fatalError("Not implemented") }
        func register(email: String, password: String) async throws -> User { fatalError("Not implemented") }
        func forgotPassword(email: String) async throws -> String { fatalError("Not implemented") }
        func changePassword(email: String, password: String, oldPassword: String) async throws -> User { fatalError("Not implemented") }
        func deleteAccount(email: String, password: String, selectedReasons: [String]) async throws -> User { fatalError("Not implemented") }
    }
    
    @Test func testTask_subscribesToUserSession() async {
        let store = TestStore(initialState: UserProfileFeature.State(user: nil)) {
            UserProfileFeature()
        } withDependencies: {
            $0.userSession.user = .init(user)
        }
        
        let task = await store.send(.task)
        
        await store.receive(\.userUpdated) {
            $0.user = self.user
        }
        
        await task.cancel()
    }
    
    @Test func testLoginButtonTapped_sendsDelegate() async {
        let store = TestStore(initialState: UserProfileFeature.State(user: nil)) {
            UserProfileFeature()
        }
        
        await store.send(.loginButtonTapped)
        await store.receive(\.delegate.didTapLogin)
    }
    
    @Test func testLogoutButtonTapped_success() async {
        let store = TestStore(initialState: UserProfileFeature.State(user: self.user)) {
            UserProfileFeature()
        } withDependencies: {
            // Provide a mock implementation of the auth service.
            $0.authService = MockAuthService(logoutImpl: { _ in self.user })
        }
        
        // The user is already in the state, so we can directly test the logout action.
        await store.send(.logoutButtonTapped) {
            $0.isLoading = true
        }
        
        // The mocked dependency returns immediately.
        await store.receive(\.logoutAccountResponse, .success(self.user)) {
            $0.isLoading = false
        }
        
        await store.receive(\.delegate.didLogout)
    }
    
    @Test func testLogoutButtonTapped_failure() async {
        let error = ErrorEquatable(message: "Logout failed")
        let store = TestStore(initialState: UserProfileFeature.State(user: self.user)) {
            UserProfileFeature()
        } withDependencies: {
            // Provide a mock implementation that throws an error.
            $0.authService = MockAuthService(logoutImpl: { _ in throw error })
        }
        
        await store.send(.logoutButtonTapped) {
            $0.isLoading = true
        }
        
        await store.receive(\.logoutAccountResponse, .failure(error)) {
            $0.isLoading = false
            $0.error = "Logout failed"
        }
    }
    
    @Test func testChangePasswordButtonTapped_sendsDelegate() async {
        let store = TestStore(initialState: UserProfileFeature.State(user: self.user)) {
            UserProfileFeature()
        }
        
        await store.send(.changePasswordButtonTapped(self.user))
        await store.receive(\.delegate.didTapChangePassword, self.user)
    }
    
    @Test func testDeleteAccountButtonTapped_sendsDelegate() async {
        let store = TestStore(initialState: UserProfileFeature.State(user: self.user)) {
            UserProfileFeature()
        }
        
        await store.send(.deleteAccountButtonTapped(self.user))
        await store.receive(\.delegate.didTapDeleteAccount, self.user)
    }
}
