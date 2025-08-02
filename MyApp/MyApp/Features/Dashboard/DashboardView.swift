//
//  DashboardView.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/20/25.
//


import SwiftUI
import ComposableArchitecture

struct DashboardView: View {
    let store: StoreOf<DashboardFeature>
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = store.user {
                Text("Welcome, \(user.name)!")
                    .font(.title)
                Button("Log Out") {
                    store.send(.logoutButtonTapped, animation: .default)
                }
                .padding(.top)
                
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
                    store.send(.logoutButtonTapped, animation: .default)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarBackButtonHidden()
    }
}
