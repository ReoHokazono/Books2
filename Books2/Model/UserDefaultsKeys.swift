//
//  UserDefaultsKeys.swift
//  Books2
//
//  Created by 外園玲央 on 2020/10/31.
//

import Foundation

struct UserDefaultKey {
    static let useiCloud = "useiCloud"
    static let displayImages = "displayImages"
}

extension UserDefaults {
    var useiCloud: Bool {
        get {
            guard let useiCloud = object(forKey: UserDefaultKey.useiCloud) as? Bool  else{
                return true
            }
            return useiCloud
        }
    }
}
