import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("login.email.placeholder", text: $store.email)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            
            SecureField("login.password.placeholder", text: $store.password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
            
            if let error = store.error {
                Text(LocalizedStringKey(error)).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else {
                Button("login.login.button") {
                    store.send(.loginTapped)
                }
            }
            
            Button("login.register.button") {
                store.send(.registerButtonTapped)
            }
            .padding(.top)
            
            Button("login.skip.button") {
                store.send(.skipButtonTapped)
            }
            .padding(.top)
            
            Button("login.forgotPassword.button") {
                store.send(.forgotPasswordButtonTapped)
            }
            .padding(.top)
            
        }
        .padding()
        .navigationTitle("login.screen.title")
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
                    state.error = "network.error.invalidCredentials"
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
