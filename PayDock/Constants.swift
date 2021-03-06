//
//  Constants.swift
//  PayDock
//
//  Created by Round Table Apps on 18/4/17.
//  Copyright © 2017 PayDock. All rights reserved.
//

import Foundation


/// constant values
struct Constants {
    /// charge url
    static var charge = "v1/charges"
    
    /// subscriptino url
    static let subscription = "v1/subscriptions"
    
    /// token url
    static let token = "v1/payment_sources/tokens"
    
    /// customer url
    static let customers = "v1/customers"

    private init() { }
}
