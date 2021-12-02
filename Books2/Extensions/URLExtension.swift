//
//  URLExtension.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/15.
//

import UIKit

extension URL {
    func open() {
        UIApplication.shared.open(self, options: [:], completionHandler: nil)
    }
}
