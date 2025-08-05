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
        VStack(spacing: 20) {
            if let user = store.user {
                userContentView(user)
            } else {
                guestContentView
            }
        }
        .padding()
        .navigationTitle("settings.screen.title")
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
    }
    
    @ViewBuilder
    private func userContentView(_ user: User) -> some View {
        // Reusing key from UserProfileView
        Text(String(format: NSLocalizedString("userProfile.welcome.user", comment: "Welcome message for a named user"), user.name))
            .font(.title)
        Button("settings.userProfile.button") {
            store.send(.profileTapped, animation: .default)
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var guestContentView: some View {
        // Reusing key from UserProfileView
        Text("userProfile.welcome.guest")
            .font(.title)
        // Reusing key from LoginView
        Button("login.login.button") {
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
                store: Store(initialState: SettingsFeature.State()) {
                    SettingsFeature()
                } withDependencies: {
                    $0.userSession.user = thomas
                }
            )
        }
        .previewDisplayName("Logged In")

        NavigationStack {
            SettingsView(store: Store(initialState: SettingsFeature.State()) {
                SettingsFeature()
            })
        }
        .previewDisplayName("Guest")
    }
}
