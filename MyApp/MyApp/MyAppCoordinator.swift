//
//  MyAppCoordinator.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/20/25.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators
import Foundation

@Reducer
struct MyAppCoordinator {
    enum StatusIndexState: Hashable {
        case firstLaunch, splash, loggedIn, auth
    }
    @CasePathable
    enum Action {
        case task
        case firstLaunch(AppFirstLaunchFeature.Action)
        case setStatusIndexStateSelected(StatusIndexState)
        case auth(AuthCoordinator.Action)
        case loggedIn(MainTabCoordinator.Action)
    }
    
    @ObservableState
    struct State: Equatable {
        var statusIndexselected: StatusIndexState
        var firstLaunch: AppFirstLaunchFeature.State
        var auth: AuthCoordinator.State
        var loggedIn: MainTabCoordinator.State
        
        init() {
            self.firstLaunch = .init()
            self.auth = .initialState
            self.loggedIn = .initialState
            // Bắt đầu ở trạng thái trung gian, để action `.task` quyết định luồng đi.
            self.statusIndexselected = .splash
        }
    }
    
    @Dependency(\.appLogger) var logger
    @Dependency(\.userSession) var userSession
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    var body: some ReducerOf<Self> {
        Scope(state: \.firstLaunch, action: \.firstLaunch) {
            AppFirstLaunchFeature()
        }
        
        Scope(state: \.auth, action: \.auth) {
            AuthCoordinator()
        }
        
        Scope(state: \.loggedIn, action: \.loggedIn) {
            MainTabCoordinator()
        }
        
        Reduce { state, action in
            switch action {
            case .task:
                if !self.userDefaultsService.isNotFirstLaunchApp {
                    // Lần đầu tiên mở ứng dụng, chuyển đến màn hình giới thiệu/onboarding.
                    state.statusIndexselected = .firstLaunch
                    // Đánh dấu là đã qua lần khởi chạy đầu tiên.
                    self.userDefaultsService.isNotFirstLaunchApp = true
                } else {
                    if let user = self.userSession.user, user.token.expiresAt > Date() {
                        // Nếu có token hợp lệ và chưa hết hạn, chuyển sang trạng thái đã đăng nhập.
                        state.statusIndexselected = .loggedIn
                    } else {
                        // Nếu không, chuyển sang luồng xác thực và xoá session đã hết hạn.
                        self.userSession.user = nil
                        state.statusIndexselected = .auth
                    }
                }
                
            case .firstLaunch(.delegate(.didFinishFirstLaunch)):
                state.statusIndexselected = .auth
                
            case let .auth(.delegate(.didLoginSuccessfully(user))):
                state.statusIndexselected = .loggedIn
                state.loggedIn.selectedTab = .indexed
                self.userSession.user = user
                
            case .auth(.delegate(.skipAuth)):
                state.statusIndexselected = .loggedIn
                self.userSession.user = nil
                
            case .auth(.delegate(.didChangePasswordSuccessfully)):
                state.statusIndexselected = .loggedIn
                
            case .auth(.delegate(.cancelChangePassword)):
                state.statusIndexselected = .loggedIn
                
            case .auth(.delegate(.goBackMainTab)):
                state.statusIndexselected = .loggedIn
                
            case .auth(.delegate(.didLogout)):
                state.statusIndexselected = .auth
                state.auth = .initialState
                self.userSession.user = nil
                
            case .auth(.delegate(.didDeleteAccountSuccessfully)):
                state.statusIndexselected = .auth
                state.auth = .initialState
                self.userSession.user = nil
                
            case .auth(.delegate(.cancelDeleteAccount)):
                state.statusIndexselected = .loggedIn
                
            case .loggedIn(.delegate(.profileTapped)):
                state.statusIndexselected = .auth
                state.auth.routes.push(.userProfileScreen(.init()))
                
            case .loggedIn(.delegate(.loginButtonTapped)):
                state.statusIndexselected = .auth
                state.auth.routes.goBackToRoot()
                
            case .firstLaunch, .auth, .loggedIn:
                break
                
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
        VStack {
            switch store.statusIndexselected {
            case .firstLaunch:
                AppFirstLaunchView(store: store.scope(
                        state: \.firstLaunch,
                        action: \.firstLaunch
                    )
                )
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
        .onAppear {
            store.send(.task)
        }
    }
}
