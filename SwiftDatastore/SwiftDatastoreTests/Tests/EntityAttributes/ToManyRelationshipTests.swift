//
//  ToManyRelationshipTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 16/07/2022.
//

import XCTest
import CoreData

@testable import SwiftDatastore

class ToManyRelationshipTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = Relationship.ToMany<TestObject>
    
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
    func test_get_emptySet() {
        // given

        // when
        let gotSet = sut.wrappedValue

        // then
        XCTAssertTrue(mock.mutableSetValueCalled)
        XCTAssertTrue(gotSet.isEmpty)
    }

    func test_get_notEmptySet() {
        // given
        let managedObjectMock1 = createNewManagedObject()
        let managedObjectMock2 = createNewManagedObject()

        let mutableSet = NSMutableSet(array: [managedObjectMock1, managedObjectMock2])

        mock._mutableSet = mutableSet

        // when
        let gotSet = sut.wrappedValue

        // then
        XCTAssertTrue(mock.mutableSetValueCalled)
        XCTAssertEqual(gotSet.count, mutableSet.count)
    }

    func test_set_emptySet() {
        // given
        let testObject1 = TestObject()
        
        mock._mutableSet = NSMutableSet(array: [testObject1])

        let setToSet = Set<TestObject>()

        // when
        sut.wrappedValue = setToSet

        // then
        XCTAssertTrue(mock.mutableSetValueCalled)
        XCTAssertTrue(mock._mutableSet.allObjects.isEmpty)
        
        mock._mutableSet.allObjects.forEach {
            guard let _ = $0 as? NSManagedObject else {
                XCTFail()
                return
            }
        }
    }
    
    func test_set_notEmptySet() {
        // given
        let testObject1 = TestObject()
        let testObject2 = TestObject()
        let testObject3 = TestObject()

        let setToSet = Set([testObject1, testObject2, testObject3])

        // when
        sut.wrappedValue = setToSet

        // then
        XCTAssertTrue(mock.mutableSetValueCalled)
        XCTAssertEqual(mock._mutableSet.allObjects.count, setToSet.count)
    }
    
    func test_observe_notEmptySet() {
        // given
        let managedObject1 = Set(arrayLiteral: createNewManagedObject())
        let managedObject2 = Set(arrayLiteral: createNewManagedObject())

        var gotNewValue: Set<TestObject>?

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        sut.observe { newObjects in
            gotNewValue = newObjects
            expectation.fulfill()
        }
        
        sut.observe { _ in
            expectation.fulfill()
        }

        // when
        sut.observedPropertyDidChangeValue(managedObject1, change: .insertion)
        sut.observedPropertyDidChangeValue(managedObject2, change: .insertion)
        sut.observedPropertyDidChangeValue(3, change: .replacement)

        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(gotNewValue?.count, 2)
    }
    
    func test_observe_emptySet() {
        // given
        let expectation = XCTestExpectation()
        var gotNewValue: Set<TestObject> = [TestObject()]

        sut.observe { newObjects in
            gotNewValue = newObjects
            expectation.fulfill()
        }

        // when
        sut.observedPropertyDidChangeValue(3, change: .replacement)

        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(gotNewValue.isEmpty)
    }
}
