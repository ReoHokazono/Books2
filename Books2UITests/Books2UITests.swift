//
//  Books2UITests.swift
//  Books2UITests
//
//  Created by 外園玲央 on 2020/10/27.
//

import XCTest

class Books2UITests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScreenshots() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
        }
        
        let app = XCUIApplication()
        sleep(5)
        app.tables.firstMatch.swipeDown()
        sleep(1)
        snapshot("screenshot1")
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["ハイ・ライズ, Ｊ・Ｇ・バラード, 村上博基"]/*[[".cells[\"ハイ・ライズ, Ｊ・Ｇ・バラード, 村上博基\"].buttons[\"ハイ・ライズ, Ｊ・Ｇ・バラード, 村上博基\"]",".buttons[\"ハイ・ライズ, Ｊ・Ｇ・バラード, 村上博基\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(1)
        snapshot("screenshot2")
        if UIDevice.current.userInterfaceIdiom == .phone {
            app.navigationBars.firstMatch.buttons["BookNote"].tap()
        }

        app.navigationBars["BookNote"].buttons["設定"].tap()
        
        let toggle = app.switches["photoToggle"]
        toggle.tap()
        
//        let switch2 = tablesQuery/*@START_MENU_TOKEN@*/.switches["1"]/*[[".cells[\"photo, 書影を表示\"].switches[\"1\"]",".switches[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        switch2.tap()
        app.navigationBars["設定"].buttons["完了"].tap()
//        app.tables.firstMatch.swipeDown()
        sleep(1)
        snapshot("screenshot3")

        app.navigationBars["BookNote"].buttons["設定"].tap()

        sleep(1)
        snapshot("screenshot4")
        toggle.tap()
        app.navigationBars["設定"].buttons["完了"].tap()
//        app.tables.firstMatch.swipeDown()

        app.navigationBars["BookNote"].searchFields["検索"].tap()
        sleep(1)
        snapshot("screenshot5")
    }
    
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
