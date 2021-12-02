//
//  ISBNFormatter.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/06.
//

import Foundation

extension String {
    var digits: String {
        if isEmpty {
            return ""
        }
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

class ISBNFormatter {
    
    func string(_ rawStr: String) -> String {
        let str = rawStr.filter{ $0 != " " }.digits
        
        if str.count < 3 {
            return str
        } else if str.count == 3 {
            return str 
        } else if str.count == 4 {
            return
                substr(str: str, from: 0, length: 3) + " " +
                substr(str: str, from: 3, length: 1) 
        } else if str.count < 12 {
            let after = str.index(str.startIndex, offsetBy: 4)
            return
                substr(str: str, from: 0, length: 3) + " " +
                substr(str: str, from: 3, length: 1) + " " + String(str[after...])
        } else if str.count == 12 {
            return
                substr(str: str, from: 0, length: 3) + " " +
                substr(str: str, from: 3, length: 1) + " " +
                substr(str: str, from: 4, length: 8)
        } else if str.count >= 13 {
            return
                substr(str: str, from: 0, length: 3) + " " +
                substr(str: str, from: 3, length: 1) + " " +
                substr(str: str, from: 4, length: 8) + " " +
                substr(str: str, from: 12, length: 1)
        }
        return ""
    }
    
    func code(_ rawStr: String) -> String? {
        let str = rawStr.filter{ $0 != " " }.digits
        if str.count == 13 {
            return str
        } else {
            return nil
        }
    }

    private func substr(str: String, from: Int, length: Int) -> String {
        let fromIndex = str.index(str.startIndex, offsetBy: from)
        let toIndex = str.index(str.startIndex, offsetBy: from + length - 1)
        return String(str[fromIndex...toIndex])
    }
}
