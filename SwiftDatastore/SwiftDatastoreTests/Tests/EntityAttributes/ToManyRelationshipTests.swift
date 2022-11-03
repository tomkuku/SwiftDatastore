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
    func test_getEmptySet() {
        // when
        let gotSet = sut.wrappedValue
        
        // then
        XCTAssertTrue(gotSet.isEmpty)
        XCTAssertTrue(mock.mutableSetValueCalled)
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
    }
    
    func test_getNotEmptySet() {
        // given
        let managedObjectMock1 = createNewManagedObject()
        let managedObjectMock2 = createNewManagedObject()
        
        let mutableSet = NSMutableSet(array: [managedObjectMock1, managedObjectMock2])
        
        mock._mutableSet = mutableSet
        
        // when
        let gotSet = sut.wrappedValue
        
        // then
        XCTAssertEqual(gotSet.count, mutableSet.count)
        XCTAssertTrue(mock.mutableSetValueCalled)
        XCTAssertTrue(mock.willAccessValueCalled)
        XCTAssertTrue(mock.didAccessValueCalled)
    }
    
    func test_setEmptySet() {
        // given
        mock._mutableSet = NSMutableSet(array: [createNewManagedObject()])
        
        // when
        sut.wrappedValue = Set<TestObject>()
        
        // then
        XCTAssertTrue(mock.mutableSetValueCalled)
        XCTAssertTrue(mock.willChangeValueSetCalled)
        XCTAssertTrue(mock.didChangeValueSetCalled)
        XCTAssertTrue(mock._mutableSet.allObjects.isEmpty)
    }
    
    func test_setNotEmptySet() {
        // given
        let setToSet = Set([TestObject(), TestObject(), TestObject()])
        
        // when
        sut.wrappedValue = setToSet
        
        // then
        XCTAssertTrue(mock.mutableSetValueCalled)
        XCTAssertTrue(mock.willChangeValueSetCalled)
        XCTAssertTrue(mock.didChangeValueSetCalled)
        XCTAssertEqual(mock._mutableSet.allObjects.count, setToSet.count)
    }
    
    func test_observeEmptySet() {
        // given
        let expectation = XCTestExpectation()
        var gotNewValue = Set([TestObject()])
        
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
    
    func test_observeNotEmptySet() {
        // given
        var closureNewValue: Set<TestObject>?
        
        let expectation = XCTestExpectation()
        
        sut.observe { newObjects in
            closureNewValue = newObjects
            expectation.fulfill()
        }
        
        let newSet = Set([createNewManagedObject(), createNewManagedObject()])
        
        // when
        sut.observedPropertyDidChangeValue(newSet, change: .insertion)
        sut.observedPropertyDidChangeValue(nil, change: .replacement)
        
        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(closureNewValue?.count, 2)
    }
}
