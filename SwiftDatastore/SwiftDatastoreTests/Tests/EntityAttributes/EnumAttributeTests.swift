//
//  EnumAttributeTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 20/07/2022.
//

import XCTest
import CoreData

@testable import SwiftDatastore

class EnumAttributeTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = Attribute.Enum<TestEnum>
    
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
    func test_get_nilValue() {
        // when
        let gotValue = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.getValueCalled)
        XCTAssertNil(gotValue)
    }
    
    func test_get_notNilValue() {
        // given
        mock._value = 1
        
        // when
        let gotValue = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.getValueCalled)
        XCTAssertEqual(gotValue, .one)
    }
    
    func test_set_notNilvalue() {
        // given
        let caseToSet = TestEnum.one
        
        // when
        sut.wrappedValue = caseToSet
        
        // then
        let setValue = mock._value as? Int
        
        XCTAssertTrue(mock.setValueCalled)
        XCTAssertEqual(setValue, 1)
    }
    
    func test_set_nilValue() {
        // given
        let caseToSet: TestEnum? = nil
        
        // when
        sut.wrappedValue = caseToSet
        
        // then
        let setValue = mock._value as? Int
        
        XCTAssertTrue(mock.setValueCalled)
        XCTAssertNil(setValue)
    }
    
    func test_observe_value() {
        // given
        let newValue = 2
        var gotNewValue: TestEnum?
        
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
        XCTAssertEqual(gotNewValue, .two)
    }
    
    func test_observe_nilValue() {
        // given
        let expectation = XCTestExpectation()
        var gotNewValue: TestEnum?
        
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
    
    // MARK: TestEnum
    enum TestEnum: Int {
        case one = 1
        case two = 2
    }
}
