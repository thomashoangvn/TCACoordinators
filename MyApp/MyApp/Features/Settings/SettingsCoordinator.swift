//
//  SettingsCoordinator.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/31/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable, .hashable)
enum ScreenSetting {
    case settingsScreen(SettingsFeature)
}

extension ScreenSetting.State: Identifiable {
    var id: UUID {
        switch self {
        case let .settingsScreen(state):
            state.id
            
        }
    }
}

struct SettingsCoordinatorView: View {
    let store: StoreOf<SettingsCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .settingsScreen(store):
                SettingsView(store: store)
            }
        }
    }
}

@Reducer
struct SettingsCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(
            routes: [.root(.settingsScreen(.init()), embedInNavigationView: true)]
        )
        var routes: IdentifiedArrayOf<Route<ScreenSetting.State>>
    }
    
    @CasePathable
    enum Action {
        case router(IdentifiedRouterActionOf<ScreenSetting>)

        case delegate(Delegate)
        @CasePathable
        enum Delegate: Sendable {
            case profileTapped
            case loginButtonTapped
            
            init(action: SettingsFeature.Action.Delegate) {
                switch action {
                case .profileTapped:
                    self = .profileTapped
                case .loginButtonTapped:
                    self = .loginButtonTapped
                }
            }
        }
    }
    
    @Dependency(\.appLogger) var logger
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(_, .settingsScreen(.delegate(action)))):
                return .send(.delegate(.init(action: action)))
                
            case .router, .delegate:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
        .observe(using: logger)
    }
}
