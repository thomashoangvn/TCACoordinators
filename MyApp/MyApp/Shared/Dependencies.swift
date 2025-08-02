//
//  Dependencies.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/30/25.
//
import ComposableArchitecture
import Combine

private enum AuthServiceKey: DependencyKey {
    static let liveValue: AuthServiceProtocol = NetworkService.shared
}

extension DependencyValues {
    var authService: AuthServiceProtocol {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
}

private enum UserSessionKey: DependencyKey {
    static let liveValue: UserSession = UserSession.shared
}

extension DependencyValues {
    var userSession: UserSession {
        get { self[UserSessionKey.self] }
        set { self[UserSessionKey.self] = newValue }
    }
}
