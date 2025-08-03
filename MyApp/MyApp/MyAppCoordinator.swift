//
//  MyAppCoordinator.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/20/25.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer
struct MyAppCoordinator {
    enum StatusIndexState: Hashable {
        case firstLaunch, splash, loggedIn, auth 
    }
    @CasePathable
    enum Action {
        case setStatusIndexStateSelected(StatusIndexState)
        case auth(AuthCoordinator.Action)
        case loggedIn(MainTabCoordinator.Action)
    }
    
    @ObservableState
    struct State: Equatable {
        var statusIndexselected: StatusIndexState
        
        var auth = AuthCoordinator.State.initialState
        var loggedIn = MainTabCoordinator.State.initialState

        init() {
            // Kiểm tra phiên người dùng hợp lệ khi khởi động.
            if let user = UserSession.shared.user, user.token.expiresAt > Date() {
                // Nếu có token hợp lệ và chưa hết hạn, chuyển đến trạng thái đã đăng nhập.
                self.statusIndexselected = .loggedIn
            } else {
                // Nếu không, chuyển đến luồng xác thực và xoá mọi phiên đã hết hạn.
                UserSession.shared.user = nil
                self.statusIndexselected = .auth
            }
        }
    }

    @Dependency(\.appLogger) var logger
    
    var body: some ReducerOf<Self> {
        Scope(state: \.auth, action: \.auth) {
            AuthCoordinator()
        }
        
        Scope(state: \.loggedIn, action: \.loggedIn) {
            MainTabCoordinator()
        }

        
        Reduce { state, action in
            switch action {
                
            case let .auth(.delegate(.didLoginSuccessfully(user))):
                state.statusIndexselected = .loggedIn
                state.loggedIn.selectedTab = .indexed
                UserSession.shared.user = user
                return .none
                
            case .auth(.delegate(.skipAuth)):
                state.statusIndexselected = .loggedIn
                UserSession.shared.user = nil
                return .none
                
            case let .auth(.delegate(.didChangePasswordSuccessfully(user))):
                state.statusIndexselected = .loggedIn
                return .none

            case .auth(.delegate(.cancelChangePassword)):
                state.statusIndexselected = .loggedIn
                return .none

            case .auth(.delegate(.goBackMainTab)):
                state.statusIndexselected = .loggedIn
                return .none

            case .auth(.delegate(.didLogout)):
                state.statusIndexselected = .auth
                state.auth = .initialState 
                UserSession.shared.user = nil
                return .none
                
            case .auth(.delegate(.didDeleteAccountSuccessfully)):
                state.statusIndexselected = .auth
                state.auth = .initialState
                UserSession.shared.user = nil
                return .none

            case .auth(.delegate(.cancelDeleteAccount)):
                state.statusIndexselected = .loggedIn
                return .none

            case let .loggedIn(.delegate(.profileTapped(user))):
                state.statusIndexselected = .auth
                state.auth.routes.push(.userProfileScreen(.init(user: user)))
                return .none
                
            case .loggedIn(.delegate(.loginButtonTapped)):
                state.statusIndexselected = .auth
                state.auth.routes.goBackToRoot()
                return .none
                
            case .auth, .loggedIn:
                return .none
                
            case let .setStatusIndexStateSelected(index):
                state.statusIndexselected = index
                
            }
            return .none
        }
        .observe(using: logger)
        
    }
    
}

// AppCoordinatorView
struct MyAppCoordinatorView: View {
    @Bindable var store: StoreOf<MyAppCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.statusIndexselected {
                case .firstLaunch:
                    Text("firstLaunch")
                case .splash:
                    Text("splash")
                case .auth:
                    AuthCoordinatorView(
                        store: store.scope(
                            state: \.auth,
                            action: \.auth
                        )
                    )
                case .loggedIn:
                    MainTabCoordinatorView(store: store.scope(state: \.loggedIn, action: \.loggedIn))
                    
                }
            }
        }
    }
}
