//
//  SettingsFeature.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/31/25.
//

import ComposableArchitecture
import TCAComposer
import SwiftUI

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        let id = UUID()
        var user: User?
    }
    
    @CasePathable
    enum Action {
        case task
        case userUpdated(User?)
        /// Một action được gửi khi người dùng nhấn vào nút hồ sơ.
        case profileTapped
        /// Một action được gửi khi người dùng nhấn vào nút đăng nhập.
        case loginButtonTapped
        
        case delegate(Delegate)
        @CasePathable
        enum Delegate {
            /// Thông báo cho parent rằng nút hồ sơ đã được nhấn.
            case profileTapped(User)
            /// Thông báo cho parent rằng nút đăng nhập đã được nhấn.
            case loginButtonTapped
        }
    }
    
    @Dependency(\.userSession) var userSession
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await user in self.userSession.$user.values {
                        await send(.userUpdated(user))
                    }
                }

            case let .userUpdated(user):
                state.user = user
                return .none

            case .profileTapped:
                guard let user = state.user else { return .none }
                return .send(.delegate(.profileTapped(user)))
                
            case .loginButtonTapped:
                return .send(.delegate(.loginButtonTapped))
                
            case .delegate:
                return .none
            }
        }
    }
}
