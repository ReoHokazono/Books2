//
//  UIDeviceExtension.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/20.
//

import Foundation
import UIKit

extension UIDevice {

    public var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
