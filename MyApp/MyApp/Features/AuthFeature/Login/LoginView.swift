import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $store.email)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $store.password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
            
            if let error = store.error {
                Text(error).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else {
                Button("Login") {
                    store.send(.loginTapped)
                }
            }
            
            Button("Don't have an account? Register") {
                store.send(.registerButtonTapped)
            }
            .padding(.top)
            
            Button("Skip Login") {
                store.send(.skipButtonTapped)
            }
            .padding(.top)
            
            Button("forgotPassword") {
                store.send(.forgotPasswordButtonTapped)
            }
            .padding(.top)
            
        }
        .padding()
    }
}
