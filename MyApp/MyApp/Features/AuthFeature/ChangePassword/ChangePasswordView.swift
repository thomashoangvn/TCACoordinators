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
    }
}
