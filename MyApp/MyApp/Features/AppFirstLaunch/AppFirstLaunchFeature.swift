//
//  AppFirstLaunchFeature.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/5/25.
//

import Foundation
import ComposableArchitecture
import AppTrackingTransparency
import UserNotifications

@Reducer
struct AppFirstLaunchFeature {
    
    @ObservableState
    enum Step: Equatable, Hashable {
        case welcome
        case terms
        case notifications
        case tracking
    }
    
    @ObservableState
    struct State: Equatable, Hashable {
        let id = UUID()
        var step: Step = .welcome
        var isLoading = false
        var error: String?
        var termsContent: String?
        var policyContent: String?
        var hasAcceptedTerms = false
        var hasAcceptedPolicy = false
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        // User actions
        case nextButtonTapped
        case termsStepAppeared
        case acceptAgreementsButtonTapped
        case requestNotificationPermissionButtonTapped
        case requestTrackingPermissionButtonTapped
        case finishButtonTapped
        
        // Internal responses
        case termsResponse(Result<String, ErrorEquatable>)
        case policyResponse(Result<String, ErrorEquatable>)
        case notificationPermissionResponse(Result<Bool, ErrorEquatable>)
        case trackingPermissionResponse(ATTrackingManager.AuthorizationStatus)
        
        case delegate(Delegate)
        @CasePathable
        enum Delegate: Equatable {
            case didFinishFirstLaunch
        }
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    @Dependency(\.userNotificationsClient) var userNotificationsClient
    @Dependency(\.appTrackingClient) var appTrackingClient
    @Dependency(\.termsClient) var termsClient
    @Dependency(\.policyClient) var policyClient
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                guard state.step == .welcome else { return .none }
                state.step = .terms
                // Trigger fetching terms when moving to the terms step
                return .send(.termsStepAppeared)
                
            case .termsStepAppeared:
                // Fetch both terms and policy only if they haven't been fetched yet.
                guard state.termsContent == nil && state.policyContent == nil else { return .none }
                state.isLoading = true
                return .run { send in
                    // Use a task group to fetch concurrently
                    await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            await send(.termsResponse(
                                await Result { try await self.termsClient.fetch() }
                                    .mapError { ErrorEquatable(message: $0.localizedDescription) }
                            ))
                        }
                        group.addTask {
                            await send(.policyResponse(
                                await Result { try await self.policyClient.fetch() }
                                    .mapError { ErrorEquatable(message: $0.localizedDescription) }
                            ))
                        }
                    }
                }
                
            case let .termsResponse(.success(content)):
                state.termsContent = content
                if state.policyContent != nil || state.error != nil {
                    state.isLoading = false
                }
                return .none
                
            case let .termsResponse(.failure(error)):
                state.isLoading = false
                let format = NSLocalizedString("firstLaunch.error.loadFailed", comment: "Error message when terms/policy fail to load")
                state.error = String(format: format, error.message)
                return .none
                
            case let .policyResponse(.success(content)):
                state.policyContent = content
                if state.termsContent != nil || state.error != nil {
                    state.isLoading = false
                }
                return .none
                
            case let .policyResponse(.failure(error)):
                state.isLoading = false
                let format = NSLocalizedString("firstLaunch.error.loadFailed", comment: "Error message when terms/policy fail to load")
                state.error = String(format: format, error.message)
                return .none
                
            case .acceptAgreementsButtonTapped:
                guard state.step == .terms, state.hasAcceptedTerms, state.hasAcceptedPolicy else { return .none }
                self.userDefaultsService.isTutorialCompleted = true
                state.step = .notifications
                return .none
                
            case .requestNotificationPermissionButtonTapped:
                guard state.step == .notifications else { return .none }
                state.isLoading = true
                return .run { send in
                    await send(.notificationPermissionResponse(
                        await Result { try await self.userNotificationsClient.requestAuthorization([.alert, .sound, .badge]) }
                            .mapError { ErrorEquatable(message: $0.localizedDescription) }
                    ))
                }
                
            case let .notificationPermissionResponse(.success(granted)):
                state.isLoading = false
                self.userDefaultsService.isNotificationOn = granted
                state.step = .tracking
                return .none
                
            case .notificationPermissionResponse(.failure):
                state.isLoading = false
                self.userDefaultsService.isNotificationOn = false // Treat as not granted
                state.step = .tracking // Still continue to the next step
                return .none
                
            case .requestTrackingPermissionButtonTapped:
                guard state.step == .tracking else { return .none }
                state.isLoading = true
                return .run { send in
                    // The 1-second sleep might be unnecessary as the system dialog is modal.
                    // Removing it will result in a faster user experience.
                    let status = await self.appTrackingClient.requestAuthorization()
                    await send(.trackingPermissionResponse(status))
                }
                
            case let .trackingPermissionResponse(status):
                state.isLoading = false
                // Save the user's choice for later use
                self.userDefaultsService.trackingAuthorizationStatus = status
                return .send(.delegate(.didFinishFirstLaunch))
                
            case .finishButtonTapped:
                return .send(.delegate(.didFinishFirstLaunch))
                
            case .binding(_):
                return .none
                
            case .delegate(_):
                return .none
                
            }
        }
    }
}

// MARK: - Dependencies

import Dependencies

struct TermsClient {
    var fetch: () async throws -> String
}

extension TermsClient: DependencyKey {
    static let liveValue = Self(
        fetch: {
            let url = URL(string: "https://www.apple.com/legal/internet-services/terms/site.html")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8) ?? ""
        }
    )
    static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )
}

extension DependencyValues {
    var termsClient: TermsClient {
        get { self[TermsClient.self] }
        set { self[TermsClient.self] = newValue }
    }
}

struct PolicyClient {
    var fetch: () async throws -> String
}

extension PolicyClient: DependencyKey {
    static let liveValue = Self(
        fetch: {
            // Assuming a similar URL for the policy
            let url = URL(string: "https://www.apple.com/legal/privacy/en-ww/")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8) ?? ""
        }
    )
    static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )
}

extension DependencyValues {
    var policyClient: PolicyClient {
        get { self[PolicyClient.self] }
        set { self[PolicyClient.self] = newValue }
    }
}

struct UserNotificationsClient {
    var requestAuthorization: (UNAuthorizationOptions) async throws -> Bool
}

extension UserNotificationsClient: DependencyKey {
    static let liveValue = Self(
        requestAuthorization: { options in
            try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        }
    )
    
    static let testValue = Self(
        requestAuthorization: unimplemented("\(Self.self).requestAuthorization")
    )
}

extension DependencyValues {
    var userNotificationsClient: UserNotificationsClient {
        get { self[UserNotificationsClient.self] }
        set { self[UserNotificationsClient.self] = newValue }
    }
}

struct AppTrackingClient {
    var requestAuthorization: () async -> ATTrackingManager.AuthorizationStatus
}

extension AppTrackingClient: DependencyKey {
    static let liveValue = Self(
        requestAuthorization: {
            await ATTrackingManager.requestTrackingAuthorization()
        }
    )
    
    static let testValue = Self(
        requestAuthorization: unimplemented("\(Self.self).requestAuthorization")
    )
}

extension DependencyValues {
    var appTrackingClient: AppTrackingClient {
        get { self[AppTrackingClient.self] }
        set { self[AppTrackingClient.self] = newValue }
    }
}
