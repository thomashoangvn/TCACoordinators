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
        let reasons = [
            "Bad experience with mobile app",
            "Don't need the account anymore",
            "Duplicated enrolment",
            "Never registered",
            "Personal reason",
            "Other"
        ]

        var user: User?
        var email: String
        var password: String = ""
        var selectedReasons: [String] = []
        var otherReasonText: String = ""
        var iConfirm = false
        var isLoading = false
        var error: String?

        init(user: User) {
            self.user = user
            self.email = user.email
        }
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
                if user == nil {
                    // Session has expired, notify the parent.
                    return .send(.delegate(.sessionExpired))
                }
                return .none
                
            case let .reasonTapped(reason):
                if let index = state.selectedReasons.firstIndex(of: reason) {
                    state.selectedReasons.remove(at: index)
                    if reason == "Other" {
                        state.otherReasonText = ""
                    }
                } else {
                    state.selectedReasons.append(reason)
                }
                return .none
            case .deleteAccountTapped:
                guard state.user != nil else {
                    state.error = "Your session has expired. Please log in again."
                    return .none
                }
                guard !state.password.isEmpty else {
                    state.error = "Passwords do not empty"
                    return .none
                }
                guard !state.selectedReasons.isEmpty else {
                    state.error = "Please select at least one reason for deleting your account."
                    return .none
                }
                if state.selectedReasons.contains("Other"), state.otherReasonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    state.error = "Please specify your reason in the 'Other' field."
                    return .none
                }
                guard state.iConfirm else {
                    state.error = "Please confirm you want to delete your account."
                    return .none
                }
                state.isLoading = true
                state.error = nil
                var finalReasons = state.selectedReasons.filter { $0 != "Other" }
                if state.selectedReasons.contains("Other") {
                    finalReasons.append("Other: \(state.otherReasonText.trimmingCharacters(in: .whitespacesAndNewlines))")
                }
                return .run { [email = state.email, password = state.password, finalReasons] send in
                    await send(.deleteAccountResponse(
                        await Result { try await self.authService.deleteAccount(email: email, password: password, selectedReasons: finalReasons) }
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
