//
//  Authentication.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation

public actor Authentication {
    ///
    /// Optional:
    /// Why actor here?
    /// I can't imagine situation where we need safety here due to concurrent environments.
    /// Barier is not changed from anywhere and it can be static let inside `class Authentication`
    ///
    var barier: String
    
    ///
    /// Optional:
    /// Bearer is a static let, declared in API
    /// No need to use another class just to init it with static let of auth bearer
    ///
    public init(barier: String) {
        self.barier = barier
    }
}
