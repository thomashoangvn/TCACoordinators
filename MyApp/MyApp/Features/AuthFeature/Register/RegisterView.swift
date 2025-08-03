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
        .navigationTitle("Register")
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
                    state.error = "Passwords do not match."
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
