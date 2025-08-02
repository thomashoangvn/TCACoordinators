//
//  UserProfileView.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/30/25.
//

import SwiftUI
import ComposableArchitecture

struct UserProfileView: View {
    let store: StoreOf<UserProfileFeature>
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Back To MainTab") {
                store.send(.back, animation: .default)
            }
            .padding()
            
            if let user = store.user {
                Text("Welcome, \(user.name)!")
                    .font(.title)
                
                if let error = store.error {
                    Text(error).foregroundColor(.red)
                }
                
                if store.isLoading {
                    ProgressView()
                } else {
                    Button("Log Out") {
                        store.send(.logoutButtonTapped, animation: .default)
                    }
                    .padding(.top)
                }
                
                Button("Change Password") {
                    store.send(.changePasswordButtonTapped(user), animation: .default)
                }
                .padding(.top)
                
                Button("Delete Account") {
                    store.send(.deleteAccountButtonTapped(user), animation: .default)
                }
                .padding(.top)
                
            } else {
                Text("Welcome, Guest!")
                    .font(.title)
                Button("Login") {
                    store.send(.loginButtonTapped, animation: .default)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Account")
        .navigationBarBackButtonHidden()
        .task {
            store.send(.task)
        }
    }
}
