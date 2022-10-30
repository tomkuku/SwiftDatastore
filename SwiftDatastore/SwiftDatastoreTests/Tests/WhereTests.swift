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

        // when
        sut = \.$age > 25
        
        // then
        XCTAssertEqual(sut.predicateFormat, "age > 25")
    }
    
    func test_greaterThanOrEqualTo() {
        // when
        sut = \.$wight >= 25.8
        
        // then
        XCTAssertEqual(sut.predicateFormat, "wight >= 25.8")
    }
    
    func test_lessThan() {
        // when
        sut = \.$height < 176.3
        
        // then
        XCTAssertEqual(sut.predicateFormat, "height < 176.3")
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

    func test_and() {
        // when
        sut = \.$age >= 25 && \.$height < 183.8

        // then
        XCTAssertEqual(sut.predicateFormat, "age >= 25 AND height < 183.8")
    }

    func test_or() {
        // when
        sut = \.$salary >= 700 || \.$age == 21
        
        // then
        XCTAssertEqual(sut.predicateFormat, "salary >= 700 OR age == 21")
    }
}

fileprivate extension Where {
    var predicateFormat: String {
        predicate.predicateFormat
    }
}
