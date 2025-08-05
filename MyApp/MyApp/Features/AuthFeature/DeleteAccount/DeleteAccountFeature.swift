//
//  DeleteAccountFeature.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/29/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DeleteAccountFeature {
    @ObservableState

    struct State: Equatable, Hashable {
        let id = UUID()
        static let otherReasonKey = "deleteAccount.reason.other"
        let reasonKeys = [
            "deleteAccount.reason.badExperience",
            "deleteAccount.reason.noLongerNeeded",
            "deleteAccount.reason.duplicate",
            "deleteAccount.reason.neverRegistered",
            "deleteAccount.reason.personal",
            Self.otherReasonKey
        ]

        var user: User?
        var email: String = ""
        var password: String = ""
        var selectedReasonKeys: [String] = []
        var otherReasonText: String = ""
        var iConfirm = false
        var isLoading = false
        var error: String?

        init() {}
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case task
        case userUpdated(User?)
        case reasonTapped(String)
        case deleteAccountTapped
        case cancelDeleteAccoutButtonTapped
        case deleteAccountResponse(Result<User, ErrorEquatable>)
        
        case delegate(Delegate)
        @CasePathable
        enum Delegate: Equatable {
            case deleteAccountSuccessful(User)
            case cancelDelete
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
                    // Session has expired, notify the parent.
                    return .send(.delegate(.sessionExpired))
                }
                return .none
                
            case let .reasonTapped(reasonKey):
                if let index = state.selectedReasonKeys.firstIndex(of: reasonKey) {
                    state.selectedReasonKeys.remove(at: index)
                    if reasonKey == State.otherReasonKey {
                        state.otherReasonText = ""
                    }
                } else {
                    state.selectedReasonKeys.append(reasonKey)
                }
                return .none
            case .deleteAccountTapped:
                guard state.user != nil else {
                    state.error = "deleteAccount.error.sessionExpired"
                    return .none
                }
                guard !state.password.isEmpty else {
                    state.error = "deleteAccount.error.passwordEmpty"
                    return .none
                }
                guard !state.selectedReasonKeys.isEmpty else {
                    state.error = "deleteAccount.error.noReasonSelected"
                    return .none
                }
                if state.selectedReasonKeys.contains(State.otherReasonKey), state.otherReasonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    state.error = "deleteAccount.error.otherReasonEmpty"
                    return .none
                }
                guard state.iConfirm else {
                    state.error = "deleteAccount.error.confirmationRequired"
                    return .none
                }
                state.isLoading = true
                state.error = nil
                
                // Convert keys to localized strings for the backend service.
                var finalReasons = state.selectedReasonKeys
                    .filter { $0 != State.otherReasonKey }
                    .map { NSLocalizedString($0, comment: "") }
                if state.selectedReasonKeys.contains(State.otherReasonKey) {
                    let otherLocalized = NSLocalizedString(State.otherReasonKey, comment: "")
                    finalReasons.append("\(otherLocalized): \(state.otherReasonText.trimmingCharacters(in: .whitespacesAndNewlines))")
                }
                return .run { [email = state.email, password = state.password, finalReasons] send in
                    await send(.deleteAccountResponse(
                        await Result { try await self.authService.deleteAccount(email, password, finalReasons) }
                            .mapError {
                                ($0 as? ErrorEquatable) ?? ErrorEquatable(message: $0.localizedDescription)
                            }
                    ))
                }
                
            case let .deleteAccountResponse(.success(user)):
                state.isLoading = false
                // Account deleted successfully, we can navigate away.
                return .send(.delegate(.deleteAccountSuccessful(user)))
                
            case let .deleteAccountResponse(.failure(error)):
                state.isLoading = false
                state.error = error.message
                return .none
                
            case .cancelDeleteAccoutButtonTapped:
                return .send(.delegate(.cancelDelete))
                
            case .delegate:
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}
