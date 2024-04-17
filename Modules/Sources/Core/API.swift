//
//  API.swift
//
//
//  Created by Vadim Marchenko on 11.04.2024.
//

import Foundation

public enum API {
    
    public static var baseURL: URL {
        /// 
        /// Optional:
        /// Interesting implementation URL here.
        /// We can use URL Components for similar much safer aproach.
        ///
        guard let url = URL(string: "https://" + "api.json-generator.com") else {
            fatalError("Base URL not available")
        }
        return url
    }
    
    public static var barrier: String {
        ///
        /// Optional:
        /// Naming confuse. Barrier probably is meant Bearer token?
        ///
        return "vf9y8r25pkqkemrk21dyjktqo7rs751apk4yjyrl"
    }
}
