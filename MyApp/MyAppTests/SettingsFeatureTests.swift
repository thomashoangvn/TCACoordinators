//
//  SettingsFeatureTests.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/3/25.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import MyApp

@MainActor
struct SettingsFeatureTests {
    // A mock user for use in tests.
    private var user = User(id: UUID(0), name: "Thomas", email: "thomas@example.com")
    
    @Test func testTask_subscribesToUserSession() async {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.userSession.user = .init(user)
        }
        
        let task = await store.send(.task)
        
        await store.receive(\.userUpdated) {
            $0.user = self.user
        }
        
        await task.cancel()
    }
    
    @Test func testProfileTapped_whenLoggedIn_sendsDelegate() async {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.userSession.user = .init(user)
        }
        
        let task = await store.send(.task)
        
        await store.receive(\.userUpdated) {
            $0.user = self.user
        }
        
        await store.send(.profileTapped)
        await store.receive(\.delegate.profileTapped, self.user)
        
        await task.cancel()
    }
    
    @Test func testLoginButtonTapped_sendsDelegate() async {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.userSession.user = .init(nilLiteral: ())
        }
        
        await store.send(.loginButtonTapped)
        await store.receive(\.delegate.loginButtonTapped)
        
    }
}
