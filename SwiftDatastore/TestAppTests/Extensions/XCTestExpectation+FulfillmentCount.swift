//
//  XCTestExpectation+FulfillmentCount.swift
//  DemoAppTests
//
//  Created by Kukułka Tomasz on 21/09/2022.
//

import Foundation
import XCTest

extension XCTestExpectation {
    convenience init(fulfillmentCount: Int) {
        self.init()
        self.expectedFulfillmentCount = fulfillmentCount
    }
}
