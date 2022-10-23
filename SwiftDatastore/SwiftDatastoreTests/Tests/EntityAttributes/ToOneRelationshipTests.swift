//
//  ToOneRelationshipTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import XCTest
import CoreData
import Hamcrest

@testable import SwiftDatastore

class ToOneRelationshipTests: XCTestCase {

    // MARK: Properties
    typealias SutType = Relationship.ToOne<TestObject>

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
    func test_get_nilObject() {
        // when
        let gotValue = sut.wrappedValue

        // then
        assertThat(mock.getValueCalled == true)
        assertThat(gotValue, nilValue())
    }

    func test_get_notNilObject() {
        // given
        let managedObject = createNewManagedObject()
        mock._value = managedObject

        // when
        guard let gotValue = sut.wrappedValue else {
            XCTFail("Got value is nil.")
            return
        }

        // then
        assertThat(mock.getValueCalled == true)

        XCTAssertTrue(type(of: gotValue) == TestObject.self)
    }

    func test_set_value() {
        // given
        let managedObjectWrapperMock = ManagedObjectWrapperMock()
        managedObjectWrapperMock._managedObject = createNewManagedObject()
        let objectToSet = TestObject(managedObjectWrapper: managedObjectWrapperMock)

        // when
        sut.wrappedValue = objectToSet

        // then
        assertThat(mock.setValueCalled == true)

        guard let _ = mock._value as? NSManagedObject else {
            XCTFail()
            return
        }
    }

    func test_set_nilValue() {
        // given
        let valueToSet: TestObject? = nil

        // when
        sut.wrappedValue = valueToSet

        // then
        let setValue = mock._value as? TestObject

        assertThat(mock.setValueCalled == true)
        assertThat(setValue, nilValue())
    }
    
    func test_observe_value() {
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
        assertThat(gotNewValue, not(nil))
    }
}
