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
    var mock: ManagedObjectWrapperMock!
    var observerMock: ManagedObjectObserverMock!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        mock = ManagedObjectWrapperMock()
        sut = SutType()
        sut.managedObjectWrapper = mock
        
        observerMock = ManagedObjectObserverMock()
        
        sut.managedObjectObserver = observerMock
    }
    
    override func tearDown() {
        mock = nil
        sut = nil
        observerMock = nil
        super.tearDown()
    }
    
    // MARK: Tests
    func test_getNotSetValue() {
        // given
        
        // when
        let gotValue = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.getValueCalled)
        XCTAssertNil(gotValue)
    }
    
    func test_getSetValue() {
        // given
        let setValue = 3
        mock._value = setValue
        
        // when
        let gotValue = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.getValueCalled)
        XCTAssertEqual(gotValue, setValue)
    }
    
    func test_setValue() {
        // given
        let valueToSet = 3
        
        // when
        sut.wrappedValue = valueToSet
        
        let setValue = mock._value as? Int
        
        // then
        XCTAssertTrue(mock.setValueCalled)
        XCTAssertEqual(setValue, valueToSet)
    }
    
    func test_setNilValue() {
        // given
        let valueToSet: Int? = nil
        
        mock._value = 3
        
        // when
        sut.wrappedValue = valueToSet
        
        let setValue = mock._value as? Int
        
        // then
        XCTAssertTrue(mock.setValueCalled)
        XCTAssertNil(setValue)
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
