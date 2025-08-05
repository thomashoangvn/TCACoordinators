//
//  AppDelegate.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/5/25.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        return true
    }
    
}
