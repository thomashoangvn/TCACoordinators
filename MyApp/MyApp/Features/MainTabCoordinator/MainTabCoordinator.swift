//
//  MainTabCoordinator.swift
//  TCACoordinatorsExample
//
//  Created by Thomas Hoang on 7/23/25.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

// MainTabCoordinator
@Reducer
struct MainTabCoordinator {
    enum Tab: Hashable {
        case identified, indexed, app, form, settingsTab, deeplinkOpened
    }
    
    enum Deeplink {
        case identified(IdentifiedCoordinator.Deeplink)
    }
    
    enum Action: Sendable {
        case identified(IdentifiedCoordinator.Action)
        case indexed(IndexedCoordinator.Action)
        case app(GameApp.Action)
        case form(FormAppCoordinator.Action)
        case settings(SettingsCoordinator.Action)
        case deeplinkOpened(Deeplink)
        case tabSelected(Tab)
        
        case delegate(Delegate)
        @CasePathable
        enum Delegate: Sendable {
            case profileTapped(User)
            case loginButtonTapped
        }
        
    }
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State(
            identified: .initialState,
            indexed: .initialState,
            app: .initialState,
            form: .initialState,
            settings: .initialState,
            selectedTab: .app
        )
        
        var identified: IdentifiedCoordinator.State
        var indexed: IndexedCoordinator.State
        var app: GameApp.State
        var form: FormAppCoordinator.State
        var settings: SettingsCoordinator.State
        
        var selectedTab: Tab
        
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.indexed, action: \.indexed) {
            IndexedCoordinator()
        }
        Scope(state: \.identified, action: \.identified) {
            IdentifiedCoordinator()
        }
        Scope(state: \.app, action: \.app) {
            GameApp()
        }
        Scope(state: \.form, action: \.form) {
            FormAppCoordinator()
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsCoordinator()
        }
        Reduce { state, action in
            switch action {
            case let .deeplinkOpened(.identified(.showNumber(number))):
                state.selectedTab = .identified
                if state.identified.routes.canPush == true {
                    state.identified.routes.push(.numberDetail(.init(number: number)))
                } else {
                    state.identified.routes.presentSheet(.numberDetail(.init(number: number)), embedInNavigationView: true)
                }
            case let .tabSelected(tab):
                state.selectedTab = tab
                
            case let .settings(.delegate(.profileTapped(user))):
                return .send(.delegate(.profileTapped(user)))

            case .settings(.delegate(.loginButtonTapped)):
                return .send(.delegate(.loginButtonTapped))
                
            case .identified, .indexed, .app, .form, .settings, .delegate:
                return .none
            }
            return .none
        }
    }
}

// MainTabCoordinatorView
struct MainTabCoordinatorView: View {
    @Bindable var store: StoreOf<MainTabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                IndexedCoordinatorView(
                    store: store.scope(
                        state: \.indexed,
                        action: \.indexed
                    )
                )
                .tabItem { Text("Indexed") }
                .tag(MainTabCoordinator.Tab.indexed)
                
                IdentifiedCoordinatorView(
                    store: store.scope(
                        state: \.identified,
                        action: \.identified
                    )
                )
                .tabItem { Text("Identified") }
                .tag(MainTabCoordinator.Tab.identified)
                
                AppCoordinatorView(
                    store: store.scope(
                        state: \.app,
                        action: \.app
                    )
                )
                .tabItem { Text("Game") }
                .tag(MainTabCoordinator.Tab.app)
                
                FormAppCoordinatorView(
                    store: store.scope(
                        state: \.form,
                        action: \.form
                    )
                )
                .tabItem { Text("Form") }
                .tag(MainTabCoordinator.Tab.form)
                
                SettingsCoordinatorView(
                    store: store.scope(
                        state: \.settings,
                        action: \.settings
                    )
                )
                .tabItem { Text("Settings") }
                .tag(MainTabCoordinator.Tab.settingsTab)
                
            }.onOpenURL { _ in
                // In reality, the URL would be parsed into a Deeplink.
                let deeplink = MainTabCoordinator.Deeplink.identified(.showNumber(42))
                store.send(.deeplinkOpened(deeplink))
            }
        }
    }
}
