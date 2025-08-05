//
//  UserProfileFeature.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/30/25.
//

import ComposableArchitecture
import SwiftUI


@Reducer
struct UserProfileFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        let id = UUID()
        var user: User? = nil
        
        var isLoading = false
        var error: String?
        
    }

    @CasePathable
    enum Action {
        case onAppear
        case onDisappear
        case userUpdated(User?)
        case back
        case loginButtonTapped
        case logoutButtonTapped
        case logoutAccountResponse(Result<User, ErrorEquatable>)
        case changePasswordButtonTapped
        case deleteAccountButtonTapped
        
        case delegate(Delegate)
        @CasePathable
        enum Delegate: Equatable {
            case didTapLogin
            case didLogout
            case didTapChangePassword
            case didTapDeleteAccount
            case didTapBack
        }
    }
    
    private enum CancelID { case userSessionSubscription }
    
    @Dependency(\.authService) var authService
    @Dependency(\.userSession) var userSession
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    for await user in self.userSession.$user.values {
                        await send(.userUpdated(user))
                    }
                }
                .cancellable(id: CancelID.userSessionSubscription)
                
            case .onDisappear:
                return .cancel(id: CancelID.userSessionSubscription)
                
            case let .userUpdated(user):
                state.user = user
                return .none
                
            case .logoutButtonTapped:
                state.isLoading = true
                state.error = nil
                guard let user = state.user else { return .none }
                return .run { send in
                    await send(.logoutAccountResponse(
                        await Result { try await self.authService.logout(user) }
                            .mapError {
                                ($0 as? ErrorEquatable) ?? ErrorEquatable(message: $0.localizedDescription)
                            }
                    ))
                }
                
            case .logoutAccountResponse(.success):
                state.isLoading = false
                state.user = nil
                self.userSession.user = nil
                return .send(.delegate(.didLogout))
                
            case let .logoutAccountResponse(.failure(error)):
                state.isLoading = false
                state.error = error.message
                return .none
                
            case .loginButtonTapped:
                return .send(.delegate(.didTapLogin))
                
            case .changePasswordButtonTapped:
                return .send(.delegate(.didTapChangePassword))
                
            case .deleteAccountButtonTapped:
                return .send(.delegate(.didTapDeleteAccount))
                
            case .back:
                return .send(.delegate(.didTapBack))
                
            case .delegate:
                return .none
            
           
            }
            return .none
        }
    }
}
