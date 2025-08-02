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
