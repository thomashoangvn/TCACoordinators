//
//  ChangePasswordView.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/29/25.
//

import SwiftUI
import ComposableArchitecture

struct ChangePasswordView: View {
    @Bindable var store: StoreOf<ChangePasswordFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            // Reusing a key for consistency
            TextField("login.email.placeholder", text: $store.email)
                .textContentType(.emailAddress)
                .disabled(true)
                .textFieldStyle(.roundedBorder)
            
            SecureField("changePassword.oldPassword.placeholder", text: $store.oldPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            SecureField("changePassword.newPassword.placeholder", text: $store.password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            SecureField("changePassword.confirmPassword.placeholder", text: $store.confirmPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            if let error = store.error {
                Text(LocalizedStringKey(error)).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else {
                Button("changePassword.submit.button") {
                    store.send(.changePasswordTapped)
                }
            }
            
            Button("changePassword.cancel.button") {
                store.send(.cancelChangePasswordButtonTapped)
            }
            .padding(.top)
        }
        .padding()
        .task {
            store.send(.task)
        }
        .navigationTitle("changePassword.screen.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
import ComposableArchitecture

struct ChangePasswordView_Previews: PreviewProvider {
    static let user = User(id: UUID(), name: "Blob", email: "blob@example.com", token: .init(value: "preview-token", expiresAt: .distantFuture))

    static var previews: some View {
        NavigationStack {
            ChangePasswordView(
                store: Store(
                    initialState: ChangePasswordFeature.State()
                ) {
                    ChangePasswordFeature()
                } withDependencies: {
                    $0.userSession.user = user
                }
            )
        }
        .previewDisplayName("Default")

        NavigationStack {
            ChangePasswordView(
                store: Store(
                    initialState: {
                        var state = ChangePasswordFeature.State()
                        state.isLoading = true
                        return state
                    }()
                ) {
                    ChangePasswordFeature()
                }
            )
        }
        .previewDisplayName("Loading")

        NavigationStack {
            ChangePasswordView(
                store: Store(
                    initialState: {
                        var state = ChangePasswordFeature.State()
                        state.error = "changePassword.error.incorrectOldPassword"
                        return state
                    }()
                ) {
                    ChangePasswordFeature()
                } withDependencies: {
                    $0.userSession.user = user
                }
            )
        }
        .previewDisplayName("Error")
    }
}
#endif
