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

private let thomas = User(id: UUID(), name: "Thomas", email: "thomas@example.com", token: .init(value: "preview-token", expiresAt: .distantFuture))

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(
                store: Store(initialState: SettingsFeature.State(user: thomas)) {
                    SettingsFeature()
                } withDependencies: {
                    $0.userSession.user = .init(thomas)
                }
            )
        }
        .previewDisplayName("Logged In")

        NavigationStack {
            SettingsView(
                store: Store(initialState: SettingsFeature.State(user: nil)) {
                    SettingsFeature()
                } withDependencies: {
                    $0.userSession.user = .init(nilLiteral: () )
                }
            )
        }
        .previewDisplayName("Guest")
    }
}
