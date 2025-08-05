//
//  ForgotPasswordView.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/28/25.
//

import SwiftUI
import ComposableArchitecture

struct ForgotPasswordView: View {
    @Bindable var store: StoreOf<ForgotPasswordFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("forgotPassword.email.placeholder", text: $store.email)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            
            if let error = store.error {
                Text(LocalizedStringKey(error)).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else {
                Button("forgotPassword.submit.button") {
                    store.send(.forgotTapped)
                }
            }
            // Reusing a key from the login screen for consistency
            Button("login.register.button") {
                store.send(.registerButtonTapped)
            }
            .padding(.top)
            
            Button("forgotPassword.skip.button") {
                store.send(.skipButtonTapped)
            }
            .padding(.top)
            
        }
        .padding()
        .navigationTitle("forgotPassword.screen.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
import ComposableArchitecture

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ForgotPasswordView(
                store: Store(initialState: ForgotPasswordFeature.State()) {
                    ForgotPasswordFeature()
                }
            )
        }
        .previewDisplayName("Default")

        NavigationStack {
            ForgotPasswordView(
                store: Store(initialState: {
                    var state = ForgotPasswordFeature.State()
                    state.isLoading = true
                    return state
                }()) {
                    ForgotPasswordFeature()
                }
            )
        }
        .previewDisplayName("Loading")

        NavigationStack {
            ForgotPasswordView(
                store: Store(initialState: {
                    var state = ForgotPasswordFeature.State()
                    state.error = NSLocalizedString("forgotPassword.error.emailNotFound", comment: "Error when email is not found")
                    return state
                }()) {
                    ForgotPasswordFeature()
                }
            )
        }
        .previewDisplayName("Error")
    }
}
#endif
