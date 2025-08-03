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
            TextField("Email", text: $store.email)
                .textContentType(.emailAddress)
                .disabled(true)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Old Password", text: $store.oldPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $store.password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Confirm Password", text: $store.confirmPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            if let error = store.error {
                Text(error).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else {
                Button("Submit Change Password") {
                    store.send(.changePasswordTapped)
                }
            }
            
            Button("Cancel Change Password") {
                store.send(.cancelChangePasswordButtonTapped)
            }
            .padding(.top)
        }
        .padding()
        .task {
            store.send(.task)
        }
        .navigationTitle("Change Password")
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
                    initialState: ChangePasswordFeature.State(user: user)
                ) {
                    ChangePasswordFeature()
                }
            )
        }
        .previewDisplayName("Default")

        NavigationStack {
            ChangePasswordView(
                store: Store(
                    initialState: {
                        var state = ChangePasswordFeature.State(user: user)
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
                        var state = ChangePasswordFeature.State(user: user)
                        state.error = "The old password is not correct."
                        return state
                    }()
                ) {
                    ChangePasswordFeature()
                }
            )
        }
        .previewDisplayName("Error")
    }
}
#endif
