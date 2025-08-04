//
//  ForgotPasswordFeature.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/28/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ForgotPasswordFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        let id = UUID()
        
        var email: String = ""
        var isLoading = false
        var error: String?
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case registerButtonTapped
        case skipButtonTapped
        case forgotTapped
        case forgotPasswordResponse(Result<String, ErrorEquatable>)
        case delegate(Delegate)
        
        @CasePathable
        enum Delegate: Equatable {
            case sendForgotSuccessful(String)
            case skip
            case didTapRegister
        }
    }
    
    @Dependency(\.authService) var authService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .registerButtonTapped:
                return .send(.delegate(.didTapRegister))
                
            case .forgotTapped:
                state.isLoading = true
                state.error = nil
                return .run { [email = state.email] send in
                    await send(.forgotPasswordResponse(
                        await Result { try await self.authService.forgotPassword(email) }
                            .mapError {
                                ($0 as? ErrorEquatable) ?? ErrorEquatable(message: $0.localizedDescription)
                            }
                    ))
                }
                
            case let .forgotPasswordResponse(.success(codes)):
                state.isLoading = false
                print("forgotPasswordResponse: \(codes)")
                return .send(.delegate(.sendForgotSuccessful(codes)))
                
            case let .forgotPasswordResponse(.failure(error)):
                state.isLoading = false
                state.error = error.message
                return .none
                
            case .delegate:
                return .none
                
            case .skipButtonTapped:
                return .send(.delegate(.skip))
                
            case .binding(_):
                return .none
            }
        }
    }
}
