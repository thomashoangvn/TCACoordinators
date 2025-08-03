import ComposableArchitecture
import Foundation

@Reducer
struct RegisterFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        let id = UUID()
        
        var email: String = ""
        var password: String = ""
        var confirmPassword: String = ""
        var isLoading = false
        var error: String?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case registerTapped
        case forgotPasswordButtonTapped
        case skipButtonTapped
        case loginButtonTapped
        case registerResponse(Result<User, ErrorEquatable>)
        
        case delegate(Delegate)
        @CasePathable
        enum Delegate: Equatable {
            case registerSuccessful(User)
            case didTapLogin
            case skip
            case didTapForgotPassWord
        }
        
    }
    
    @Dependency(\.authService) var authService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .registerTapped:
                guard state.password == state.confirmPassword else {
                    state.error = "Passwords do not match"
                    return .none
                }
                state.isLoading = true
                state.error = nil
                return .run { [email = state.email, password = state.password] send in
                    await send(.registerResponse(
                        await Result { try await self.authService.register(email: email, password: password) }
                            .mapError {
                                ($0 as? ErrorEquatable) ?? ErrorEquatable(message: $0.localizedDescription)
                            }
                    ))
                }
                
            case let .registerResponse(.success(user)):
                state.isLoading = false
                print("Registered: \(user)")
                return .send(.delegate(.registerSuccessful(user)))
                
            case let .registerResponse(.failure(error)):
                state.isLoading = false
                state.error = error.message
                return .none
                
            case .loginButtonTapped:
                return .send(.delegate(.didTapLogin))
                
            case .forgotPasswordButtonTapped:
                return .send(.delegate(.didTapForgotPassWord))
                
            case .skipButtonTapped:
                return .send(.delegate(.skip))
                
            case .delegate:
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}
