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
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView(
                store: Store(initialState: LoginFeature.State()) {
                    LoginFeature()
                }
            )
        }
        .previewDisplayName("Default")

        NavigationStack {
            LoginView(
                store: Store(initialState: {
                    var state = LoginFeature.State()
                    state.email = "blob@example.com"
                    state.password = "password"
                    return state
                }()) {
                    LoginFeature()
                }
            )
        }
        .previewDisplayName("Input Filled")

        NavigationStack {
            LoginView(
                store: Store(initialState: {
                    var state = LoginFeature.State()
                    state.isLoading = true
                    return state
                }()) {
                    LoginFeature()
                }
            )
        }
        .previewDisplayName("Loading")

        NavigationStack {
            LoginView(
                store: Store(initialState: {
                    var state = LoginFeature.State()
                    state.error = "Invalid email or password."
                    return state
                }()) {
                    LoginFeature()
                }
            )
        }
        .previewDisplayName("Error")
    }
}
#endif
