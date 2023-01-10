//
//  ToManyOrderedRelationshipTests.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 03/11/2022.
//

import XCTest

@testable import SwiftDatastore

final class ToManyOrderedRelationshipTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = Relationship.ToMany<TestObject>.Ordered<TestObject>
    
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
    func test_getEmptySet() {
        // when
        let gotSet = sut.wrappedValue
        
        // then
        XCTAssertTrue(gotSet.isEmpty)
        XCTAssertTrue(mock.mutableOrderedSetValueCalled)
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
    }
    
    func test_getNotEmptySet() {
        // given
        let _mutableOrderedSet = NSMutableOrderedSet(array: [createNewManagedObject(),
                                                             createNewManagedObject()])
        
        mock._mutableOrderedSet = _mutableOrderedSet
        
        // when
        let gotSet = sut.wrappedValue
        
        // then
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
        XCTAssertTrue(mock.mutableOrderedSetValueCalled)
        XCTAssertEqual(gotSet.count, _mutableOrderedSet.count)
    }
    
    func test_setEmptySet() {
        // given
        mock._mutableSet = NSMutableSet(array: [createNewManagedObject()])
        
        // when
        sut.wrappedValue = []
        
        // then
        XCTAssertTrue(mock.mutableOrderedSetValueCalled)
        XCTAssertTrue(mock.willChangeValueOrderedSetCalled)
        XCTAssertTrue(mock.didChangeValueOrderedSetCalled)
        XCTAssertTrue(mock._mutableOrderedSet.array.isEmpty)
    }
    
    func test_setNotEmptySet() {
        // given
        let arrayToSet = [TestObject(), TestObject(), TestObject()]
        
        // when
        sut.wrappedValue = arrayToSet
        
        // then
        XCTAssertTrue(mock.mutableOrderedSetValueCalled)
        XCTAssertTrue(mock.willChangeValueOrderedSetCalled)
        XCTAssertTrue(mock.didChangeValueOrderedSetCalled)
        XCTAssertEqual(mock._mutableOrderedSet.array.count, arrayToSet.count)
    }
    
    func test_observeEmptySet() {
        // given
        let expectation = XCTestExpectation()
        var gotNewValue: [TestObject]?

        sut.observe { newObjects in
            gotNewValue = newObjects
            expectation.fulfill()
        }

        // when
        sut.observedPropertyDidChangeValue(3, change: .setting)

        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(gotNewValue?.isEmpty, true)
    }

    func test_observeNotEmptySet() {
        // given
        var gotNewValue: [TestObject]?

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        sut.observe { newObjects in
            gotNewValue = newObjects
            expectation.fulfill()
        }

        sut.observe { _ in
            expectation.fulfill()
        }

        let newArra = [createNewManagedObject(), createNewManagedObject()]
        
        // when
        sut.observedPropertyDidChangeValue(newArra, change: .replacement)
        sut.observedPropertyDidChangeValue(3, change: .setting)

        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(gotNewValue?.count, 2)
    }
}
