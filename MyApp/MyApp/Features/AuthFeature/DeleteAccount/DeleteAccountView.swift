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
            Text("If you delete your account, all your personal information and associated data from the platform's servers will be forfeited.")
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 12) {
                Text("Reason for leaving")
                    .font(.headline)
                ForEach(store.reasons, id: \.self) { reason in
                    VStack(alignment: .leading) {
                        Button {
                            store.send(.reasonTapped(reason))
                        } label: {
                            HStack {
                                Text(reason)
                                Spacer()
                                if store.selectedReasons.contains(reason) {
                                    Image(systemName: "checkmark.square.fill")
                                } else {
                                    Image(systemName: "square")
                                }
                            }
                            .foregroundColor(.primary)
                        }
                        if reason == "Other" && store.selectedReasons.contains("Other") {
                            TextField("Please specify", text: $store.otherReasonText)
                                .textFieldStyle(.roundedBorder)
                                .transition(.opacity.animation(.default))
                        }
                    }
                }
            }

            TextField("Email", text: $store.email)
                .textContentType(.emailAddress)
                .disabled(true)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $store.password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)

            Button {
                store.iConfirm.toggle()
            } label: {
                HStack {
                    Image(systemName: store.iConfirm ? "largecircle.fill.circle" : "circle")
                    Text("I confirm and proceed")
                    Spacer()
                }
            }
            .foregroundColor(.primary)
            
            if let error = store.error {
                Text(error).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else {
                Button("Confirm Delete Account") {
                    store.send(.deleteAccountTapped)
                }
            }
            
            Button("Cancel Delete Account") {
                store.send(.cancelDeleteAccoutButtonTapped)
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Delete Account")
        .task {
            store.send(.task)
        }
    }
}
