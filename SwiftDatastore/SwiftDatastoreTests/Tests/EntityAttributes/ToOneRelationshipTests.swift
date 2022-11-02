//
//  ToOneRelationshipTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import XCTest
import CoreData

@testable import SwiftDatastore

class ToOneRelationshipTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = Relationship.ToOne<TestObject>
    
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
    func test_getNilObject() {
        // when
        let gotValue = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.primitiveValueCalled)
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
        XCTAssertNil(gotValue)
    }
    
    func test_getNotNilObject() {
        // given
        let managedObject = createNewManagedObject()
        mock._primitiveValue = managedObject
        
        // when
        guard let gotValue = sut.wrappedValue else {
            XCTFail("Got value is nil.")
            return
        }
        
        // then
        XCTAssertTrue(mock.primitiveValueCalled)
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
        XCTAssertTrue(type(of: gotValue) == TestObject.self)
    }
    
    func test_setNilValue() {
        // given
        let valueToSet: TestObject? = nil
        
        // when
        sut.wrappedValue = valueToSet
        
        // then
        XCTAssertNil(mock._primitiveValue as? TestObject)
        XCTAssertTrue(mock.setPrimitiveValueCalled)
        XCTAssertTrue(mock.willChangeValueCalled)
        XCTAssertTrue(mock.didChangeValueCalled)
    }
    
    func test_setNotNilValue() {
        // given
        let objectToSet = TestObject()
        
        // when
        sut.wrappedValue = objectToSet
        
        // then
        XCTAssertTrue(mock.setPrimitiveValueCalled)
        XCTAssertTrue(mock.willChangeValueCalled)
        XCTAssertTrue(mock.didChangeValueCalled)
        XCTAssertNotNil(mock._primitiveValue as? NSManagedObject)
    }
    
    func test_observealue() {
        // given
        let newValue = createNewManagedObject()
        var gotNewValue: TestObject?
        
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
        XCTAssertNotNil(gotNewValue)
    }
}
