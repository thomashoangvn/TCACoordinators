//
//  SettingsView.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/31/25.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 20) {
                if let user = store.user {
                    userContentView(user)
                } else {
                    guestContentView
                }
            }
            .padding()
            .navigationTitle("Settings")
            .task {
                store.send(.task)
            }
        }
    }
    
    @ViewBuilder
    private func userContentView(_ user: User) -> some View {
        Text("Welcome, \(user.name)!")
            .font(.title)
        Button("User Profile") {
            store.send(.profileTapped, animation: .default)
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var guestContentView: some View {
        Text("Welcome, Guest!")
            .font(.title)
        Button("Login") {
            store.send(.loginButtonTapped, animation: .default)
        }
        .padding(.top)
    }
}
