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
        sut = nil
        mock = nil
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
        mock._primitiveValue = 1
        
        // when
        let gotValue = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.primitiveValueCalled)
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
        XCTAssertEqual(gotValue, .one)
    }
    
    func test_setNilValue() {
        // given
        let caseToSet: TestEnum? = nil
        
        // when
        sut.wrappedValue = caseToSet
        
        // then
        let setValue = mock._primitiveValue as? Int
        
        XCTAssertTrue(mock.setPrimitiveValueCalled)
        XCTAssertTrue(mock.willChangeValueCalled)
        XCTAssertTrue(mock.didChangeValueCalled)
        XCTAssertNil(setValue)
    }
    
    func test_setNotNilvalue() {
        // given
        let caseToSet = TestEnum.one
        
        // when
        sut.wrappedValue = caseToSet
        
        // then
        let setValue = mock._primitiveValue as? Int
        
        XCTAssertTrue(mock.setPrimitiveValueCalled)
        XCTAssertTrue(mock.willChangeValueCalled)
        XCTAssertTrue(mock.didChangeValueCalled)
        XCTAssertEqual(setValue, 1)
    }
    
    func test_observeNilValue() {
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
    
    func test_observeValue() {
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
}
