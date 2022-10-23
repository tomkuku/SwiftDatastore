//
//  NotOptionalAttributeTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import XCTest
import CoreData
import Hamcrest

@testable import SwiftDatastore

class NotOptionalAttributeTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = Attribute.NotOptional<Int>
    
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
    func test_getSetValue() {
        // given
        let setValue = 3
        mock._value = setValue
        
        // when
        let gotValue = sut.wrappedValue
        
        // then
        assertThat(mock.getValueCalled == true)
        assertThat(gotValue, equalTo(setValue))
    }
    
    func test_setValue() {
        // given
        let valueToSet = 3
        
        // when
        sut.wrappedValue = valueToSet
        
        // then
        let setValue = mock._value as! Int
        
        assertThat(mock.setValueCalled == true)
        assertThat(setValue, equalTo(valueToSet))
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
        assertThat(gotNewValue, equalTo(newValue))
    }
}
