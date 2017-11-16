//
//  VWOSegmentEvaluatorTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 16/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest
import UIKit

class VWOSegmentEvaluatorTests: XCTestCase {

    func fromJSON(file: String) -> [String: Any] {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: file, ofType: "json")!
        let url = URL(fileURLWithPath: path)
        let str = try! String(contentsOf: url, encoding: .utf8)
        return str.jsonToDictionary
    }

    override func setUp() { super.setUp() }

    override func tearDown() { super.tearDown() }

    func testCustomVariable() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.customVariables = ["user" : "Paid"]
        let json = fromJSON(file: "CustomVariable")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json))

        evaluator.customVariables = ["user" : "free"]
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json))
    }

    func testAppVersion() {
        
    }

    func testPredefined() {
        let iPhoneJSON = fromJSON(file: "PredefinediPhone")
        let iPadJSON = fromJSON(file: "PredefinediPad")
        let returingJSON = fromJSON(file: "PredefinedReturningUser")
        let newUserJSON = fromJSON(file: "PredefinedNewUser")

        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iPhoneJSON))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iPadJSON))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: returingJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: newUserJSON))

        evaluator.isReturning = true
        evaluator.appleDeviceType = .iPad
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iPhoneJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iPadJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: returingJSON))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: newUserJSON))
    }
}

