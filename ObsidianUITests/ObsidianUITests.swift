//
//  ObsidianUITests.swift
//  ObsidianUITests
//
//  Created by Eli Slade on 2018-05-25.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import XCTest

class ObsidianUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        if let simulator = ProcessInfo().environment["SIMULATOR_DEVICE_NAME"] {
            if simulator.contains("iPhone") {
                XCUIDevice.shared.orientation = .portrait
            }
            
            if simulator.contains("iPad") {
                XCUIDevice.shared.orientation = .landscapeLeft
            }
        }
        
        setupSnapshot(app)
        app.launchArguments = ["UITesting"]
        app.launch()
    }
    
    var isLoggedOut = true
    
    func makeSureAppIsLoggedIn() {
        if isLoggedOut {
            XCUIApplication().images["AppIcon"].press(forDuration: 0.3);
            isLoggedOut = false
        }
    }
    
    var isForLocalization = false
    
    func testForAppStore() {
        testPositions()
        testBalances()
        testOrders()
        testSearch()
    }
    
    func testForLocalization() {
        isForLocalization = true
        testLoginScreen()
        testPositions()
        testBalances()
        testOrders()
        testSearch()
    }
    
    func testLoginScreen() {
        snapshot("LoginScreen", timeWaitingForIdle: 0)
    }
    
    func testPositions() {
        makeSureAppIsLoggedIn()
        
        // symbol modal
        let button = app.tables.children(matching: .cell).element(boundBy: 1)/*@START_MENU_TOKEN@*/.buttons["PositionPriceLabel"]/*[[".buttons[\"$193.31\"]",".buttons[\"PositionPriceLabel\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let expectation = XCTNSPredicateExpectation(predicate:NSPredicate(format: "exists == true"), object: button)
        wait(for: [expectation], timeout: 1)
        button.tap()

        if isForLocalization {
            app.navigationBars["Title"].buttons["Info"].tap()
            snapshot("01-SymbolModalExpanded", timeWaitingForIdle: 0)
            app.navigationBars["Title"].buttons["Info"].tap()
        } else {
            app.otherElements["Graph View"].press(forDuration: 1)
            snapshot("01-SymbolModalGraph", timeWaitingForIdle: 0)
        }
        
        app.navigationBars["Title"]/*@START_MENU_TOKEN@*/.buttons["DismissModal"]/*[[".buttons[\"closeIndicator\"]",".buttons[\"DismissModal\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("02-Positions", timeWaitingForIdle: 0)
    }
    
    func testBalances() {
        makeSureAppIsLoggedIn()
        app.tabBars.buttons.element(boundBy: 1).tap()
        snapshot("03-Balances", timeWaitingForIdle: 0)
    }
    
    func testOrders() {
        makeSureAppIsLoggedIn()
        app.tabBars.buttons.element(boundBy: 2).tap()
        snapshot("04-Orders", timeWaitingForIdle: 0)
    }
    
    func testSearch() {
        makeSureAppIsLoggedIn()
        app.tabBars.buttons.element(boundBy: 3).tap()
        
        if isForLocalization {
            snapshot("05-Search", timeWaitingForIdle: 0)
        }
        
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("AAPL")
        snapshot("06-SearchResult", timeWaitingForIdle: 0)
    }
    
}
