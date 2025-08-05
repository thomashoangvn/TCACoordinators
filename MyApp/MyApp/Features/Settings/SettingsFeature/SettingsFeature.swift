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
        // id không cần thiết nếu State không được dùng trong IdentifiedArray và đã có Hashable.
        // Tuy nhiên, giữ lại cũng không sao.
        let id = UUID() 
        var user: User? = nil
    }
    
    @CasePathable
    enum Action {
        /// Action được gửi khi view xuất hiện để bắt đầu lắng nghe thay đổi.
        case onAppear
        /// Action được gửi khi view biến mất để huỷ lắng nghe.
        case onDisappear
        /// Một action được gửi khi người dùng nhấn vào nút hồ sơ.
        case profileTapped
        /// Một action được gửi khi người dùng nhấn vào nút đăng nhập.
        case loginButtonTapped
        /// Action nội bộ để cập nhật user từ UserSession.
        case userUpdated(User?)
        
        case delegate(Delegate)
        @CasePathable
        enum Delegate {
            /// Thông báo cho parent rằng nút hồ sơ đã được nhấn.
            case profileTapped
            /// Thông báo cho parent rằng nút đăng nhập đã được nhấn.
            case loginButtonTapped
        }
    }
    
    // ID để huỷ subscription khi view biến mất.
    private enum CancelID { case userSessionSubscription }
    
    @Dependency(\.userSession) var userSession
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Khi view xuất hiện, bắt đầu lắng nghe sự thay đổi của user trong UserSession.
                // Dữ liệu sẽ được đẩy vào qua action `userUpdated`.
                return .run { send in
                    for await user in self.userSession.$user.values {
                        await send(.userUpdated(user))
                    }
                }
                .cancellable(id: CancelID.userSessionSubscription)
                
            case .onDisappear:
                // Huỷ subscription khi view biến mất để tránh memory leak và các side effect không mong muốn.
                return .cancel(id: CancelID.userSessionSubscription)
                
            case .profileTapped:
                guard state.user != nil else { return .none }
                return .send(.delegate(.profileTapped))
                
            case .loginButtonTapped:
                return .send(.delegate(.loginButtonTapped))
                
            case let .userUpdated(user):
                state.user = user
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
