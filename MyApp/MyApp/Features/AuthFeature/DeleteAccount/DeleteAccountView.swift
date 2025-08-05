//
//  DeleteAccountView.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/29/25.
//

import SwiftUI
import ComposableArchitecture

struct DeleteAccountView: View {
    @Bindable var store: StoreOf<DeleteAccountFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            Text("deleteAccount.warning.message")
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 12) {
                Text("deleteAccount.reason.title")
                    .font(.headline)
                ForEach(store.reasonKeys, id: \.self) { reasonKey in
                    VStack(alignment: .leading) {
                        Button {
                            store.send(.reasonTapped(reasonKey))
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(reasonKey))
                                Spacer()
                                if store.selectedReasonKeys.contains(reasonKey) {
                                    Image(systemName: "checkmark.square.fill")
                                } else {
                                    Image(systemName: "square")
                                }
                            }
                            .foregroundColor(.primary)
                        }
                        if reasonKey == DeleteAccountFeature.State.otherReasonKey && store.selectedReasonKeys.contains(DeleteAccountFeature.State.otherReasonKey) {
                            TextField("deleteAccount.otherReason.placeholder", text: $store.otherReasonText)
                                .textFieldStyle(.roundedBorder)
                                .transition(.opacity.animation(.default))
                        }
                    }
                }
            }
            // Reusing a key for consistency
            TextField("login.email.placeholder", text: $store.email)
                .textContentType(.emailAddress)
                .disabled(true)
                .textFieldStyle(.roundedBorder)
            
            SecureField("deleteAccount.password.placeholder", text: $store.password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)

            Button {
                store.iConfirm.toggle()
            } label: {
                HStack {
                    Image(systemName: store.iConfirm ? "largecircle.fill.circle" : "circle")
                    Text("deleteAccount.confirm.checkbox")
                    Spacer()
                }
            }
            .foregroundColor(.primary)
            
            if let error = store.error {
                Text(LocalizedStringKey(error)).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else { 
                Button("deleteAccount.confirm.button") {
                    store.send(.deleteAccountTapped)
                }
            }
            
            Button("deleteAccount.cancel.button") {
                store.send(.cancelDeleteAccoutButtonTapped)
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("deleteAccount.screen.title")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            store.send(.task)
        }
    }
}

#if DEBUG
import ComposableArchitecture

struct DeleteAccountView_Previews: PreviewProvider {
    static let user = User(id: UUID(), name: "Blob", email: "blob@example.com", token: .init(value: "preview-token", expiresAt: .distantFuture))

    static var previews: some View {
        NavigationStack {
            DeleteAccountView(
                store: Store(initialState: DeleteAccountFeature.State()) {
                    DeleteAccountFeature()
                } withDependencies: {
                    $0.userSession.user = user
                }
            )
        }
        .previewDisplayName("Default")

        NavigationStack {
            DeleteAccountView(
                store: Store(initialState: {
                    var state = DeleteAccountFeature.State()
                    state.selectedReasonKeys = ["deleteAccount.reason.badExperience", "deleteAccount.reason.other"]
                    state.otherReasonText = "The UI is confusing."
                    state.password = "password123"
                    state.iConfirm = true
                    return state
                }()) {
                    DeleteAccountFeature()
                } withDependencies: {
                    $0.userSession.user = user
                }
            )
        }
        .previewDisplayName("Input Filled")

        NavigationStack {
            DeleteAccountView(
                store: Store(initialState: {
                    var state = DeleteAccountFeature.State()
                    state.isLoading = true
                    return state
                }()) {
                    DeleteAccountFeature()
                } withDependencies: {
                    $0.userSession.user = user
                }
            )
        }
        .previewDisplayName("Loading")

        NavigationStack {
            DeleteAccountView(
                store: Store(initialState: {
                    var state = DeleteAccountFeature.State()
                    state.error = "deleteAccount.error.passwordEmpty"
                    return state
                }()) {
                    DeleteAccountFeature()
                } withDependencies: {
                    $0.userSession.user = user
                }
            )
        }
        .previewDisplayName("Error")
    }
}
#endif
