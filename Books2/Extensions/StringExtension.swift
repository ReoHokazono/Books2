//
//  StringExtension.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/16.
//

import Foundation

extension String {
    func collationStringIfAvailable() -> String {
        applyingTransform(.hiraganaToKatakana, reverse: true)?
        .applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? self
    }
}
