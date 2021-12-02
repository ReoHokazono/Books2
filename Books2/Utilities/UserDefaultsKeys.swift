//
//  UserDefaultsKeys.swift
//  Books2
//
//  Created by 外園玲央 on 2020/10/31.
//

import Foundation

struct UserDefaultKey {
    static let displayImages = "displayImages"
    static let openAppCount  = "openAppCount"
    static let lastVersionPromptedForReview = "lastVersionPromptedForReview"
}

extension UserDefaults {
    var openAppCount: Int {
        set {
            setValue(newValue, forKey: UserDefaultKey.openAppCount)
        }
        
        get {
            integer(forKey: UserDefaultKey.openAppCount)
        }
    }
    
    var lastVersionPromptedForReview: String {
        set {
            setValue(newValue, forKey: UserDefaultKey.lastVersionPromptedForReview)
        }
        
        get {
            string(forKey: UserDefaultKey.lastVersionPromptedForReview) ?? ""
        }
    }
}
