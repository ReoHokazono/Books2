//
//  OpenBDAPITests.swift
//  Books2Tests
//
//  Created by 外園玲央 on 2020/11/12.
//

import XCTest
@testable import Books2

class OpenBDAPITests: XCTestCase {

    func testDownloadRecord() {
        let downloadExpectation = XCTestExpectation(description: "Download Book Record")
        let isbn = "9784151200533"
        OpenBDAPI.downloadRecord(isbn) { (result) in
            switch result {
            case .success(let record):
                XCTAssertEqual(record.isbn, isbn)
                XCTAssertEqual(record.title, "一九八四年")
            default:
                XCTAssert(false)
            }
            downloadExpectation.fulfill()
        }
        
        
        let notFoundExpectation = XCTestExpectation(description: "Not Found Test")
        let notFoundISBN = "9784575938906"
        OpenBDAPI.downloadRecord(notFoundISBN) { (result) in
            switch result {
            case .failure(let error):
            XCTAssertEqual(error, .notFound)
            default:
                XCTAssert(false)
            }
            notFoundExpectation.fulfill()
        }
        
        //TODO: empty str, isbn-10, invalid str
        
//        let isbn10 = "4150119554"
//        
//        let emptyStr = ""
//        
//        
//        let invalidStr = "abc"
//        wait(for: [downloadExpectation, notFoundExpectation], timeout: 5)
        
    }
}
