//
//  LetterflyUITests.swift
//  LetterflyUITests
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import XCTest

final class LetterflyUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testTermsAcceptanceAdvancesPastSafetyGate() throws {
        let app = XCUIApplication()
        app.launchArguments += ["--ui-testing"]
        app.launch()

        let title = app.staticTexts["Before you start"]
        let continueButton = app.buttons["Agree and Continue"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertTrue(continueButton.exists)

        continueButton.tap()

        let buttonDisappeared = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: continueButton
        )
        XCTAssertEqual(XCTWaiter.wait(for: [buttonDisappeared], timeout: 5), .completed)
    }

    @MainActor
    func testTermsScreenIncludesReportingAndBlockingRules() throws {
        let app = XCUIApplication()
        app.launchArguments += ["--ui-testing"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Reporting"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Blocking"].exists)
        XCTAssertTrue(app.staticTexts["Our response"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments += ["--ui-testing"]
            app.launch()
        }
    }
}
