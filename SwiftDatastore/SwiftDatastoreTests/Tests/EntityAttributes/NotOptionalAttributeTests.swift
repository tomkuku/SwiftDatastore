//
//  NotOptionalAttributeTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import XCTest
import CoreData

@testable import SwiftDatastore

class NotOptionalAttributeTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = Attribute.NotOptional<Int>
    
    var sut: SutType!
    var mock: ManagedObjectKeyValueMock!
    var observerMock: ManagedObjectObserverMock!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        mock = ManagedObjectKeyValueMock()
        observerMock = ManagedObjectObserverMock()
        sut = SutType()
        sut.key = "test-key"
        sut.managedObject = mock
        sut.managedObjectObserver = observerMock
    }
    
    override func tearDown() {
        mock = nil
        sut = nil
        observerMock = nil
        super.tearDown()
    }
    
    // MARK: Tests
    func test_getValue() {
        // given
        let setValue = 3
        mock._primitiveValue = setValue
        
        // when
        let gotValue = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.primitiveValueCalled)
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
        XCTAssertEqual(gotValue, setValue)
    }
    
    func test_setValue() {
        // given
        let valueToSet = 3
        
        // when
        sut.wrappedValue = valueToSet
        
        // then
        let setValue = mock._primitiveValue as! Int
        
        XCTAssertTrue(mock.setPrimitiveValueCalled)
        XCTAssertTrue(mock.willChangeValueCalled)
        XCTAssertTrue(mock.didChangeValueCalled)
        XCTAssertEqual(setValue, valueToSet)
    }
    
    func test_observe() {
        // given
        let newValue = 2
        var gotNewValue: Int?
        
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        sut.observe { newValue in
            gotNewValue = newValue
            expectation.fulfill()
        }
        
        sut.observe { _ in
            expectation.fulfill()
        }
        
        // when
        sut.observedPropertyDidChangeValue(newValue, change: nil)
        
        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(gotNewValue, newValue)
    }
}
