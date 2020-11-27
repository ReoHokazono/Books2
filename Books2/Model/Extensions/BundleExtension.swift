//
//  BundleExtension.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/20.
//

import Foundation

extension Bundle {
    var version: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    
    var build: String {
        object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    }
}
