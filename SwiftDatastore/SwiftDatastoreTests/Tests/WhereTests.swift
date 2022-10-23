//
//  WhereTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/08/2022.
//

import Foundation
import CoreData
import XCTest

@testable import SwiftDatastore

class WhereTests: XCTestCase {
    
    typealias SutType = Where<TestObject>
    
    var sut: SutType!
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_greatThat() {
        // given
        let age = 25
        
        // when
        sut = \.$age > age
        
        // then
        XCTAssertEqual(sut.predicateFormat, "age > \(age)")
    }
    
    func test_greaterThanOrEqualTo() {
        // given
        let wigth: Float = 55.8
        
        // when
        sut = \.$wight >= wigth
        
        // then
        XCTAssertEqual(sut.predicateFormat, "wight >= \(wigth)")
    }
    
    func test_lessThan() {
        // given
        let height: Double = 176.3
        
        // when
        sut = \.$height < height
        
        // then
        XCTAssertEqual(sut.predicateFormat, "height < \(height)")
    }
    
    func test_lessThanOrEqualTo() {
        // given
        let date = Date()
        let expectedPredicate = NSPredicate(format: "dateBirth <= %@", date as NSDate)
        
        // when
        sut = \.$dateBirth <= date
        
        // then
        XCTAssertEqual(sut.predicate, expectedPredicate)
    }
    
    func test_equalTo() {
        // given
        let isDefective = false
        
        // when
        sut = \.$isDefective == isDefective
        
        // then
        XCTAssertEqual(sut.predicateFormat, "isDefective == 0")
    }
    
    func test_equalTo_nil() {
        // when
        sut = \.$salary == nil
        
        // then
        XCTAssertEqual(sut.predicateFormat, "salary == <null>")
    }
    
    func test_notEqualTo() {
        // given
        let uuid = UUID()
        
        // when
        sut = \.$uuid != uuid
        
        // then
        XCTAssertEqual(sut.predicateFormat, "uuid != \(uuid)")
    }
    
    func test_notEqualTo_nil() {
        // when
        sut = \.$uuid != nil
        
        // then
        XCTAssertEqual(sut.predicateFormat, "uuid != <null>")
    }
    
    func test_contains() {
        // given
        let namePrefix = "My"

        // when
        sut = \.$name ?= namePrefix

        // then
        XCTAssertEqual(sut.predicateFormat, "name CONTAINS \"\(namePrefix)\"")
    }

    func test_beginsWith() {
        // given
        let namePrefix = "My"

        // when
        sut = \.$name ^= namePrefix

        // then
        XCTAssertEqual(sut.predicateFormat, "name BEGINSWITH \"\(namePrefix)\"")
    }

    func test_endsWith() {
        // given
        let namePrefix = "My"

        // when
        sut = \.$name |= namePrefix

        // then
        XCTAssertEqual(sut.predicateFormat, "name ENDSWITH \"\(namePrefix)\"")
    }

    func test_and() {
        // given
        let age = 25
        let height: Double = 183.8

        // when
        sut = \.$age >= age && \.$height < height

        // then
        XCTAssertEqual(sut.predicateFormat, "age >= 25 AND height < 183.8")
    }

    func test_or() {
        // given
        let string = "My"

        // when
        sut = (\.$isDefective == true) || (\.$name ^= string)

        // then
        XCTAssertEqual(sut.predicateFormat, "isDefective == 1 OR name BEGINSWITH \"My\"")
    }
}

fileprivate extension Where {
    var predicateFormat: String {
        predicate.predicateFormat
    }
}
