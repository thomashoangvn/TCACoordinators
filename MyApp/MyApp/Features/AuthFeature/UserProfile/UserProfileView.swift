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
            Button("userProfile.backToMain.button") {
                store.send(.back, animation: .default)
            }
            .padding()
            
            if let user = store.user {
                Text(String(format: NSLocalizedString("userProfile.welcome.user", comment: "Welcome message for a named user"), user.name))
                    .font(.title)
                
                if let error = store.error {
                    Text(LocalizedStringKey(error)).foregroundColor(.red)
                }
                
                if store.isLoading {
                    ProgressView()
                } else {
                    Button("userProfile.logout.button") {
                        store.send(.logoutButtonTapped, animation: .default)
                    }
                    .padding(.top)
                }
                
                Button("userProfile.changePassword.button") {
                    store.send(.changePasswordButtonTapped, animation: .default)
                }
                .padding(.top)
                
                Button("userProfile.deleteAccount.button") {
                    store.send(.deleteAccountButtonTapped, animation: .default)
                }
                .padding(.top)
                
            } else {
                Text("userProfile.welcome.guest")
                    .font(.title)
                // Reusing the key from the login screen
                Button("login.login.button") {
                    store.send(.loginButtonTapped, animation: .default)
                }
                .padding(.top)
            }
        }
        .navigationTitle("userProfile.screen.title")
        .navigationBarBackButtonHidden()
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
    }
}

private let thomas = User(id: UUID(), name: "Thomas", email: "thomas@example.com", token: .init(value: "preview-token", expiresAt: .distantFuture))

#Preview("Logged In") {
    NavigationView {
        UserProfileView(
            store: Store(
                initialState: UserProfileFeature.State()) {
                    UserProfileFeature()
            } withDependencies: {
                $0.userSession.user = .init(thomas)
            }
        )
    }
}

#Preview("Guest") {
    NavigationView {
        UserProfileView(
            store: Store(initialState: UserProfileFeature.State()) {
                UserProfileFeature()
            }
        )
    }
}

#Preview("Loading") {
    NavigationView {
        UserProfileView(
            store: Store(
                initialState: UserProfileFeature.State(isLoading: true)
            ) {
                UserProfileFeature()
            } withDependencies: {
                $0.userSession.user = .init(thomas)
            }
        )
    }
}

#Preview("Error") {
    NavigationView {
        UserProfileView(
            store: Store(
                initialState: UserProfileFeature.State(error: NSLocalizedString("userProfile.error.logoutFailed", comment: "Logout error message"))
            ) {
                UserProfileFeature()
            } withDependencies: {
                $0.userSession.user = .init(thomas)
            }
        )
    }
}
