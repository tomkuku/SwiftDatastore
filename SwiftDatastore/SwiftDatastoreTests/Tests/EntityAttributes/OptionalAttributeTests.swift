//
//  OptionalAttributeTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import XCTest
import CoreData

@testable import SwiftDatastore

class OptionalAttributeTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = Attribute.Optional<Int>
    
    var sut: SutType!
    var mock: ManagedObjectKeyValueMock!
    var observerMock: ManagedObjectObserverMock!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        mock = ManagedObjectKeyValueMock()
        observerMock = ManagedObjectObserverMock()
        sut = SutType()
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
    func test_getNilValue() {
        // when
        let gotValue = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.primitiveValueCalled)
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
        XCTAssertNil(gotValue)
    }
    
    func test_getNotNilValue() {
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
    
    func test_setNilValue() {
        // given
        let valueToSet: Int? = nil
        
        mock._primitiveValue = 3
        
        // when
        sut.wrappedValue = valueToSet
        
        let setValue = mock._primitiveValue as? Int
        
        // then
        XCTAssertTrue(mock.setPrimitiveValueCalled)
        XCTAssertTrue(mock.willChangeValueCalled)
        XCTAssertTrue(mock.didChangeValueCalled)
        XCTAssertNil(setValue)
    }
    
    func test_setNotNilValue() {
        // given
        let valueToSet = 3
        
        // when
        sut.wrappedValue = valueToSet
        
        let setValue = mock._primitiveValue as? Int
        
        // then
        XCTAssertTrue(mock.setPrimitiveValueCalled)
        XCTAssertTrue(mock.willChangeValueCalled)
        XCTAssertTrue(mock.didChangeValueCalled)
        XCTAssertEqual(setValue, valueToSet)
    }
    
    func test_observe_value() {
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
    
    func test_observe_nilValue() {
        // given
        let expectation = XCTestExpectation()
        var gotNewValue: Int?
        
        sut.observe { newValue in
            gotNewValue = newValue
            expectation.fulfill()
        }
        
        // when
        sut.observedPropertyDidChangeValue(nil, change: nil)
        
        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertNil(gotNewValue)
    }
}
