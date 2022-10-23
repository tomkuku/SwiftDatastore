//
//  EnumAttributeTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 20/07/2022.
//

import XCTest
import CoreData
import Hamcrest

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
        assertThat(mock.getValueCalled == true)
        assertThat(gotValue, nilValue())
    }
    
    func test_get_notNilValue() {
        // given
        mock._value = 1
        
        // when
        let gotValue = sut.wrappedValue
        
        // then
        assertThat(mock.getValueCalled == true)
        
        assertThat(gotValue, equalTo(.one))
    }
    
    func test_set_notNilvalue() {
        // given
        let caseToSet = TestEnum.one
        
        // when
        sut.wrappedValue = caseToSet
        
        // then
        let setValue = mock._value as? Int
        
        assertThat(mock.setValueCalled == true)
        assertThat(setValue, equalTo(1))
    }
    
    func test_set_nilValue() {
        // given
        let caseToSet: TestEnum? = nil
        
        // when
        sut.wrappedValue = caseToSet
        
        // then
        let setValue = mock._value as? Int
        
        assertThat(mock.setValueCalled == true)
        assertThat(setValue, nilValue())
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
        assertThat(gotNewValue, equalTo(.two))
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
        assertThat(gotNewValue, nilValue())
    }
    
    // MARK: TestEnum
    enum TestEnum: Int {
        case one = 1
        case two = 2
    }
}
