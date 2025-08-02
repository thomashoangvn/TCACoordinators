import Foundation
import ComposableArchitecture
import TCAComposer

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        let id = UUID()
        
        var email: String = ""
        var password: String = ""
        var isLoading = false
        var error: String?
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case forgotPasswordButtonTapped
        case skipButtonTapped
        case loginTapped
        case registerButtonTapped
        case loginResponse(Result<User, ErrorEquatable>)
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case didTapForgotPassWord
            case skip
            case loginSuccessful(User)
            case didTapRegister
        }
    }
    
    @Dependency(\.authService) var authService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .loginTapped:
                state.isLoading = true
                state.error = nil
                return .run { [email = state.email, password = state.password] send in
                    await send(.loginResponse(
                        await Result { try await self.authService.login(email: email, password: password) }
                            .mapError {
                                ($0 as? ErrorEquatable) ?? ErrorEquatable(message: $0.localizedDescription)
                            }
                    ))
                }
                
            case let .loginResponse(.success(user)):
                state.isLoading = false
                return .send(.delegate(.loginSuccessful(user)))
                
            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.error = error.message
                return .none
                
            case .registerButtonTapped:
                return .send(.delegate(.didTapRegister))
                
            case .forgotPasswordButtonTapped:
                return .send(.delegate(.didTapForgotPassWord))
            
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
