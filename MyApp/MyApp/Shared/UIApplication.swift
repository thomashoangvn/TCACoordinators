//
//  UIApplication.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/5/25.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
