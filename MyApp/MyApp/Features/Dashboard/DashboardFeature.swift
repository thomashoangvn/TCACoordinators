import ComposableArchitecture
import SwiftUI


@Reducer
struct DashboardFeature {
    @ObservableState
    struct State: Equatable {
        var user: User? = nil
    }
    
    enum Action: Equatable, Hashable {
        case logoutButtonTapped
        case changePasswordButtonTapped(_ user: User)
        case deleteAccountButtonTapped(_ user: User)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .logoutButtonTapped:
                return .none
                
            case .changePasswordButtonTapped(let user):
                return .none
                
            case .deleteAccountButtonTapped(let user):
                return .none
            }
        }
    }
}
