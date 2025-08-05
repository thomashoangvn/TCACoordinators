//
//  ErrorEquatable.swift
//  MyApp
//
//  Created by Thomas Hoang on 7/29/25.
//

struct ErrorEquatable: Error, Equatable {
    let message: String
    
    init(message: String = "An unknown error occurred.") {
        self.message = message
    }
    
    var localizedDescription: String { message }
}
