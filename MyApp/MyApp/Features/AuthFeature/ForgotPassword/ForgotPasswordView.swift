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
            TextField("Email", text: $store.email)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            
            if let error = store.error {
                Text(error).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else {
                Button("Submit Email") {
                    store.send(.forgotTapped)
                }
            }
            Button("Don't have an account? Register") {
                store.send(.registerButtonTapped)
            }
            .padding(.top)
            
            Button("Skip") {
                store.send(.skipButtonTapped)
            }
            .padding(.top)
            
        }
        .padding()
    }
}
