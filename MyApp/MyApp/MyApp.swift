//
//  MyApp.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/2/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyAppCoordinatorView(
                store: Store(initialState: MyAppCoordinator.State()) {
                    MyAppCoordinator()
                }
            )
        }
    }
}

#Preview("Auth Flow") {
    MyAppCoordinatorView(
        store: Store(initialState: MyAppCoordinator.State()) {
            MyAppCoordinator()
        }
    )
}

#Preview("Logged In Flow") {
    MyAppCoordinatorView(
        store: Store(
            initialState: {
                var state = MyAppCoordinator.State()
                state.statusIndexselected = .loggedIn
                return state
            }()
        ) {
            MyAppCoordinator()
        }
    )
}
