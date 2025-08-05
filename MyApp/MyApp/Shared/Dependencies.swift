//
//  Dependencies.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/30/25.
//
import ComposableArchitecture
import Combine
import XCTestDynamicOverlay

private enum AuthServiceKey: DependencyKey {
    static let liveValue: AuthService = {
        let service = NetworkService()
        return AuthService(
            logout: service.logout,
            login: service.login,
            register: service.register,
            forgotPassword: service.forgotPassword,
            changePassword: service.changePassword,
            deleteAccount: service.deleteAccount
        )
    }()
    
    static let testValue: AuthService = AuthService(
        logout: unimplemented("\(Self.self).logout"),
        login: unimplemented("\(Self.self).login"),
        register: unimplemented("\(Self.self).register"),
        forgotPassword: unimplemented("\(Self.self).forgotPassword"),
        changePassword: unimplemented("\(Self.self).changePassword"),
        deleteAccount: unimplemented("\(Self.self).deleteAccount")
    )
    
}

extension DependencyValues {
    var authService: AuthService {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
}

private enum UserSessionKey: DependencyKey {
    static let liveValue = UserSession.shared
    static let testValue: () = XCTestDynamicOverlay.unimplemented(
        """
        @Dependency(\\.userSession) was not implemented.
        
        The `UserSession` dependency is a class instance. To use it in tests, you must mock it
        and override the dependency.
        
        You can create a mock instance for your test like this:
        
        ```swift
        let userSession = UserSession(service: "test-service")
        // ... set mock properties on userSession ...
        
        let store = TestStore(...) withDependencies: {
          $0.userSession = userSession
        }
        ```
        """
    )
}

extension DependencyValues {
    var userSession: UserSession {
        get { self[UserSessionKey.self] }
        set { self[UserSessionKey.self] = newValue }
    }
}

private enum UserDefaultsServiceKey: DependencyKey {
    static let liveValue = UserDefaultsService()
    static let testValue: () = XCTestDynamicOverlay.unimplemented(
        """
        @Dependency(\\.userDefaultsService) was not implemented.
        
        To use the `UserDefaultsService` in tests, you must override the dependency with a mock
        instance. A common approach is to use an in-memory UserDefaults instance.
        
        ```swift
        let userDefaults = UserDefaults(suiteName: "test-suite")!
        userDefaults.removePersistentDomain(forName: "test-suite")
        
        let store = TestStore(...) withDependencies: {
          $0.userDefaultsService = UserDefaultsService(userDefaults: userDefaults)
        }
        ```
        """
    )
}

extension DependencyValues {
    var userDefaultsService: UserDefaultsService {
        get { self[UserDefaultsServiceKey.self] }
        set { self[UserDefaultsServiceKey.self] = newValue }
    }
}

