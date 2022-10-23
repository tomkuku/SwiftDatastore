//
//  OrderByTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/08/2022.
//

import Foundation
import XCTest

@testable import SwiftDatastore

class OrderByTests: XCTestCase {
        
    func test_asc() {
        // given
        let expectedSortDescriptor = NSSortDescriptor(key: "name", ascending: true)

        // when
        let orderBy = OrderBy.asc(\TestObject.$name)

        // then
        XCTAssertEqual(orderBy.sortDescriptor, expectedSortDescriptor)
    }
    
    func test_desc() {
        // given
        let expectedSortDescriptor = NSSortDescriptor(key: "dateBirth", ascending: false)

        // when
        let orderBy = OrderBy.desc(\TestObject.$dateBirth)

        // then
        XCTAssertEqual(orderBy.sortDescriptor, expectedSortDescriptor)
    }
}
