//
//  AppFirstLaunchView.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/5/25.
//

import SwiftUI
import ComposableArchitecture
import WebKit

struct AppFirstLaunchView: View {
    @Bindable var store: StoreOf<AppFirstLaunchFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                switch store.step {
                case .welcome:
                    WelcomeStepView(store: store)
                case .terms:
                    TermsStepView(store: store)
                case .notifications:
                    NotificationsStepView(store: store)
                case .tracking:
                    TrackingStepView(store: store)
                }
            }
            .animation(.default, value: store.step)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .overlay {
                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(2)
                        .padding()
                        .background(.black.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
    }
}

// Subview for the Welcome step
private struct WelcomeStepView: View {
    let store: StoreOf<AppFirstLaunchFeature>

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Welcome to MyApp!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Experience a safe, reliable service that will accompany you for the long term.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button("Continue") {
                store.send(.nextButtonTapped)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
        }
    }
}

// Subview for the Terms step
private struct TermsStepView: View {
    @Bindable var store: StoreOf<AppFirstLaunchFeature>

    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Terms & Policies")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            if store.termsContent != nil && store.policyContent != nil {
                TabView(selection: $selectedTab) {
                    // Terms Tab
                    WebView(htmlString: store.termsContent ?? "")
                        .tag(0)

                    // Policy Tab
                    WebView(htmlString: store.policyContent ?? "")
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(
                    Picker("", selection: $selectedTab) {
                        Text("Terms of Service").tag(0)
                        Text("Privacy Policy").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding([.horizontal, .top]),
                    alignment: .top
                )
                .border(Color.gray.opacity(0.5), width: 1)
                .padding(.horizontal)
            } else if store.error == nil {
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else if let error = store.error {
                Spacer()
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
            VStack(spacing: 16) {
                Button {
                    store.hasAcceptedTerms.toggle()
                } label: {
                    HStack {
                        Image(systemName: store.hasAcceptedTerms ? "largecircle.fill.circle" : "circle")
                        Text("I have read and agree to the terms of service.")
                        Spacer()
                    }
                }
                .foregroundColor(.primary)

                Button {
                    store.hasAcceptedPolicy.toggle()
                } label: {
                    HStack {
                        Image(systemName: store.hasAcceptedPolicy ? "largecircle.fill.circle" : "circle")
                        Text("I have read and agree to the privacy policy.")
                        Spacer()
                    }
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal)

            Button("Agree and Continue") {
                store.send(.acceptAgreementsButtonTapped)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!store.hasAcceptedTerms || !store.hasAcceptedPolicy)
            .padding()
        }
    }
}

private struct WebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

// Subview for the Notifications step
private struct NotificationsStepView: View {
    let store: StoreOf<AppFirstLaunchFeature>

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Enable Notifications")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("We will send you important updates and special offers. You can change this setting at any time.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            VStack {
                Button("Allow Notifications") {
                    store.send(.requestNotificationPermissionButtonTapped)
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Later") {
                    // Theo yêu cầu của App Store, vẫn phải hiển thị hộp thoại xin phép.
                    store.send(.requestNotificationPermissionButtonTapped)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

// Subview for the Tracking step
private struct TrackingStepView: View {
    let store: StoreOf<AppFirstLaunchFeature>

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Allow Tracking")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Your data will be used to personalize your experience and show relevant ads. We are committed to protecting your privacy.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            VStack {
                Button("Allow Tracking") {
                    store.send(.requestTrackingPermissionButtonTapped)
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("No, Thanks") {
                    // Theo yêu cầu của App Store, vẫn phải hiển thị hộp thoại xin phép.
                    store.send(.requestTrackingPermissionButtonTapped)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#if DEBUG
struct WelcomeStepView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeStepView(
            store: Store(
                initialState: AppFirstLaunchFeature.State(step: .welcome)
            ) {
                AppFirstLaunchFeature()
            }
        )
        .previewDisplayName("Welcome Step")
    }
}

struct TermsStepView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TermsStepView(
                store: Store(
                    initialState: AppFirstLaunchFeature.State(
                        step: .terms,
                        isLoading: true
                    )
                ) {
                    AppFirstLaunchFeature()
                }
            )
            .previewDisplayName("Terms Step - Loading")

            TermsStepView(
                store: Store(
                    initialState: AppFirstLaunchFeature.State(
                        step: .terms,
                        termsContent: "<h1>Terms</h1><p>This is the content of the terms of use.</p>",
                        policyContent: "<h1>Policy</h1><p>This is the content of the privacy policy.</p>"
                    )
                ) {
                    AppFirstLaunchFeature()
                }
            )
            .previewDisplayName("Terms Step - Loaded")

            TermsStepView(
                store: Store(
                    initialState: AppFirstLaunchFeature.State(
                        step: .terms,
                        error: "Could not load content. Please try again."
                    )
                ) {
                    AppFirstLaunchFeature()
                }
            )
            .previewDisplayName("Terms Step - Error")
        }
    }
}

struct NotificationsStepView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsStepView(
            store: Store(
                initialState: AppFirstLaunchFeature.State(step: .notifications)
            ) {
                AppFirstLaunchFeature()
            }
        )
        .previewDisplayName("Notifications Step")
    }
}

struct TrackingStepView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingStepView(
            store: Store(
                initialState: AppFirstLaunchFeature.State(step: .tracking)
            ) {
                AppFirstLaunchFeature()
            }
        )
        .previewDisplayName("Tracking Step")
    }
}
#endif
