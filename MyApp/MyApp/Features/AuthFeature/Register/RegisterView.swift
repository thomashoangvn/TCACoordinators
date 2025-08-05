import SwiftUI
import ComposableArchitecture

struct RegisterView: View {
    @Bindable var store: StoreOf<RegisterFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("register.email.placeholder", text: $store.email)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            
            SecureField("register.password.placeholder", text: $store.password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            SecureField("register.confirmPassword.placeholder", text: $store.confirmPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            if let error = store.error {
                Text(LocalizedStringKey(error)).foregroundColor(.red)
            }
            
            if store.isLoading {
                ProgressView()
            } else {
                Button("register.register.button") {
                    store.send(.registerTapped)
                }
            }
            Button("register.login.button") {
                store.send(.loginButtonTapped)
            }
            .padding(.top)
            
            Button("login.forgotPassword.button") {
                store.send(.forgotPasswordButtonTapped)
            }
            .padding(.top)
            
            Button("register.skip.button") {
                store.send(.skipButtonTapped)
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("register.screen.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegisterView(
                store: Store(initialState: RegisterFeature.State()) {
                    RegisterFeature()
                }
            )
        }
        .previewDisplayName("Default")

        NavigationStack {
            RegisterView(
                store: Store(initialState: {
                    var state = RegisterFeature.State()
                    state.email = "blob@example.com"
                    state.password = "password"
                    state.confirmPassword = "password"
                    return state
                }()) {
                    RegisterFeature()
                }
            )
        }
        .previewDisplayName("Input Filled")

        NavigationStack {
            RegisterView(
                store: Store(initialState: {
                    var state = RegisterFeature.State()
                    state.isLoading = true
                    return state
                }()) {
                    RegisterFeature()
                }
            )
        }
        .previewDisplayName("Loading")

        NavigationStack {
            RegisterView(
                store: Store(initialState: {
                    var state = RegisterFeature.State()
                    state.error = "register.error.passwordsDoNotMatch"
                    return state
                }()) {
                    RegisterFeature()
                }
            )
        }
        .previewDisplayName("Error")
    }
}
#endif
