//
//  AppSplashFeature.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/5/25.
//


import Foundation
import ComposableArchitecture

@Reducer
struct AppSplashFeature {
    
    @ObservableState
    struct State: Equatable, Hashable {
        let id = UUID()
        var isLoading = true
        var error: String?
        
    }
    
    enum Action: Equatable {
        case task
        case delegate(Delegate)
        
        @CasePathable
        enum Delegate: Equatable {
            case didFinishSplash
        }
    }
    
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    try await self.clock.sleep(for: .seconds(2))
                    await send(.delegate(.didFinishSplash))
                }
            case .delegate:
                return .none
            }
        }
    }
}
