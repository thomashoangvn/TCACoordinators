import SwiftUI
import ComposableArchitecture

struct RegisterView: View {
    @Bindable var store: StoreOf<RegisterFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $store.email)
                .textContentType(.emailAddress)
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
                Button("Register") {
                    store.send(.registerTapped)
                }
            }
            Button("I have an account. Login") {
                store.send(.loginButtonTapped)
            }
            .padding(.top)
            
            Button("Forgot Password?") {
                store.send(.forgotPasswordButtonTapped)
            }
            .padding(.top)
            
            Button("Skip Register") {
                store.send(.skipButtonTapped)
            }
            .padding(.top)
        }
        .padding()
    }
}
