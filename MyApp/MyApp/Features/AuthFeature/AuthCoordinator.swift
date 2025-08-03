//
//  AuthCoordinator.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/28/25.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer(state: .equatable, .hashable)
enum ScreenAuth {
    case userProfileScreen(UserProfileFeature)
    case loginScreen(LoginFeature)
    case registerScreen(RegisterFeature)
    case forgotPasswordScreen(ForgotPasswordFeature)
    case changePasswordScreen(ChangePasswordFeature)
    case deleteAccountScreen(DeleteAccountFeature)
}

extension ScreenAuth.State: Identifiable {
    var id: UUID {
        switch self {
        case let .userProfileScreen(state):
            state.id
            
        case let .loginScreen(state):
            state.id
            
        case let .registerScreen(state):
            state.id
            
        case let .forgotPasswordScreen(state):
            state.id
            
        case let .changePasswordScreen(state):
            state.id
            
        case let .deleteAccountScreen(state):
            state.id
            
        }
    }
}

struct AuthCoordinatorView: View {
    let store: StoreOf<AuthCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .userProfileScreen(store):
                UserProfileView(store: store)
                
            case let .loginScreen(store):
                LoginView(store: store)
                
            case let .registerScreen(store):
                RegisterView(store: store)
                
            case let .forgotPasswordScreen(store):
                ForgotPasswordView(store: store)
                
            case let .changePasswordScreen(store):
                ChangePasswordView(store: store)
                
            case let .deleteAccountScreen(store):
                DeleteAccountView(store: store)
                                
            }
        }
    }
}

@Reducer
struct AuthCoordinator {
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(
            routes: [.root(.loginScreen(.init()), embedInNavigationView: true)]
        )
        
        var routes: IdentifiedArrayOf<Route<ScreenAuth.State>>
    }
    @CasePathable
    enum Action {
        case router(IdentifiedRouterActionOf<ScreenAuth>)
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case goBackMainTab
            
            case didLoginSuccessfully(User)
            case skipAuth
            case didChangePasswordSuccessfully(User)
            case cancelChangePassword
            case didDeleteAccountSuccessfully(User)
            case cancelDeleteAccount
            case didLogout
        }
    }
    
    @Dependency(\.appLogger) var logger
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            // Chỉ xử lý các action từ router (các màn hình con)
            if case let .router(.routeAction(_, action)) = action {
                switch action {
                    // Xử lý delegate action từ LoginScreen
                case let .loginScreen(.delegate(delegateAction)):
                    switch delegateAction {
                    case let .loginSuccessful(user):
                        return .send(.delegate(.didLoginSuccessfully(user)))
                    case .didTapRegister:
                        state.routes.push(.registerScreen(.init()))
                        return .none
                    case .skip:
                        return .send(.delegate(.skipAuth))
                    case .didTapForgotPassWord:
                        state.routes.push(.forgotPasswordScreen(.init()))
                        return .none
                    
                    }
                    
                    // Xử lý delegate action từ RegisterScreen
                case let .registerScreen(.delegate(delegateAction)):
                    switch delegateAction {
                    case let .registerSuccessful(user):
                        state.routes.goBackToRoot()
                        return .send(.delegate(.didLoginSuccessfully(user)))
                    case .didTapLogin:
                        // Quay lại màn hình trước đó (Login)
                        state.routes.goBackToRoot()
                        return .none
                    case .skip:
                        state.routes.goBackToRoot()
                        return .send(.delegate(.skipAuth))
                    case .didTapForgotPassWord:
                        state.routes.push(.forgotPasswordScreen(.init()))
                        return .none
                    }
                    
                    // Xử lý delegate action từ ForgotPasswordScreen
                case let .forgotPasswordScreen(.delegate(delegateAction)):
                    switch delegateAction {
                    case .sendForgotSuccessful(let message):
                        // Có thể hiện alert ở đây trước khi quay lại
                        state.routes.goBackToRoot()
                        return .none
                    case .skip:
                        state.routes.goBackToRoot()
                        return .send(.delegate(.skipAuth))
                    case .didTapRegister:
                        state.routes.push(.registerScreen(.init()))
                        return .none
                    }
                    
                case let .changePasswordScreen(.delegate(delegateAction)):
                    switch delegateAction {
                    case let .changePasswordSuccessful(user):
                        state.routes.goBackToRoot()
                        return .send(.delegate(.didChangePasswordSuccessfully(user)))
                    case .cancelChangePassword:
                        state.routes.goBackToRoot()
                        return .send(.delegate(.cancelChangePassword))
                    case .sessionExpired:
                        // Session đã hết hạn, quay về màn hình đăng nhập và thông báo cho parent.
                        state.routes.goBackToRoot()
                        return .send(.delegate(.didLogout))
                    }
                    
                case let .deleteAccountScreen(.delegate(delegateAction)):
                    switch delegateAction {
                    case let .deleteAccountSuccessful(user):
                        state.routes.goBackToRoot()
                        return .send(.delegate(.didDeleteAccountSuccessfully(user)))
                    case .cancelDelete:
                        state.routes.goBackToRoot()
                        return .send(.delegate(.cancelDeleteAccount))
                    case .sessionExpired:
                        // Session đã hết hạn, quay về màn hình đăng nhập và thông báo cho parent.
                        state.routes.goBackToRoot()
                        return .send(.delegate(.didLogout))
                    
                    }
                    
                case let .userProfileScreen(.delegate(delegateAction)):
                    switch delegateAction {
                    case .didLogout:
                        // User đã đăng xuất, quay về màn hình login và báo cho coordinator cha.
                        state.routes.goBackToRoot()
                        return .send(.delegate(.didLogout))
                        
                    case let .didTapChangePassword(user):
                        // User muốn đổi mật khẩu, điều hướng tới màn hình ChangePassword.
                        state.routes.push(.changePasswordScreen(.init(user: user)))
                        return .none
                        
                    case let .didTapDeleteAccount(user):
                        // User muốn xoá tài khoản, điều hướng tới màn hình DeleteAccount.
                        state.routes.push(.deleteAccountScreen(.init(user: user)))
                        return .none
                        
                    case .didTapBack:
                        // User muốn quay lại màn hình chính của app.
                        return .send(.delegate(.goBackMainTab))
                        
                    case .didTapLogin:
                        // User (guest) nhấn nút login.
                        state.routes.goBackToRoot()
                        return .none
                    }
                    
                default: break
                }
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
        .observe(using: logger)
    }
}
