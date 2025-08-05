//
//  ChangePasswordFeature.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/29/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ChangePasswordFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        let id = UUID()

        var user: User?
        var email: String = ""
        var oldPassword: String = ""
        var password: String = ""
        var confirmPassword: String = ""
        var isLoading = false
        var error: String?

        // State sẽ được khởi tạo trống và tự cập nhật từ UserSession.
        init() {}
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case task
        case userUpdated(User?)
        case changePasswordTapped
        case cancelChangePasswordButtonTapped
        case changePasswordResponse(Result<User, ErrorEquatable>)
        
        case delegate(Delegate)
        @CasePathable
        enum Delegate: Equatable {
            case changePasswordSuccessful
            case cancelChangePassword
            case sessionExpired
        }
        
    }
    
    @Dependency(\.authService) var authService
    @Dependency(\.userSession) var userSession
    
    var body: some ReducerOf<Self> {
        BindingReducer()
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
                state.email = user?.email ?? ""
                if user == nil {
                    return .send(.delegate(.sessionExpired))
                }
                return .none
                
            case .changePasswordTapped:
                guard state.user != nil else {
                    // Reusing an existing key
                    state.error = "deleteAccount.error.sessionExpired"
                    return .none
                }
                guard state.password == state.confirmPassword else {
                    state.error = "register.error.passwordsDoNotMatch"
                    return .none
                }
                state.isLoading = true
                state.error = nil
                return .run { [email = state.email, password = state.password, oldPassword = state.oldPassword] send in
                    await send(.changePasswordResponse(
                        await Result { try await self.authService.changePassword(email, password, oldPassword) }
                            .mapError {
                                ($0 as? ErrorEquatable) ?? ErrorEquatable(message: $0.localizedDescription)
                            }
                    ))
                }
                
            case let .changePasswordResponse(.success(user)):
                state.isLoading = false
                print("change password: \(user)")
                return .send(.delegate(.changePasswordSuccessful))
                
            case let .changePasswordResponse(.failure(error)):
                state.isLoading = false
                state.error = error.message
                return .none
                
            case .cancelChangePasswordButtonTapped:
                return .send(.delegate(.cancelChangePassword))
                
            case .delegate:
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}
