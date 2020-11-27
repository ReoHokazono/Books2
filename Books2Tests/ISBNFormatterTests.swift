//
//  ISBNFormatterTests.swift
//  Books2Tests
//
//  Created by 外園玲央 on 2020/11/12.
//

import XCTest
@testable import Books2

class ISBNFormatterTests: XCTestCase {

    func testDigitsFiltering() {
        let str = "123 abc"
        XCTAssertEqual(str.digits, "123")
    }
    
    func testISBNFormatting() {
        XCTAssertEqual(ISBNFormatter().string("9784151200533"), "978 4 15120053 3")
        XCTAssertEqual(ISBNFormatter().string("978"), "978 ")
        XCTAssertEqual(ISBNFormatter().string("9784"), "978 4 ")
        XCTAssertEqual(ISBNFormatter().string("978415120053"), "978 4 15120053 ")
        XCTAssertEqual(ISBNFormatter().string("abc"), "")
    }

}
