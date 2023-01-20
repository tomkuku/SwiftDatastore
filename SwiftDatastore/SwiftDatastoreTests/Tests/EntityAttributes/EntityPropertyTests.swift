//
//  EntityPropertyTests.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 14/10/2022.
//

import Foundation
import XCTest
import Combine

@testable import SwiftDatastore

class EntityPropertyTests: XCTestCase {
    
    typealias SutType = EntityProperty<Int>
    
    var sut: SutType!
    
    var observerMock: ManagedObjectObserverMock!
    var cancellable: Set<AnyCancellable> = []
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        observerMock = ManagedObjectObserverMock()
        
        sut = SutType()
        sut.key = "test-key"
        sut.managedObject = PersistentStoreCoordinatorMock.shared.managedObject
        sut.managedObjectObserver = observerMock
    }
    
    override func tearDown() {
        sut = nil
        observerMock = nil
        super.tearDown()
    }
    
    // MARK: Tests
    func test_informAboutNewValue() {
        // given
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 4
        
        sut
            .newValuePublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        sut
            .newValuePublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        let closure1 = { (newValue: Int) in
            expectation.fulfill()
        }
        
        let closure2 = { (newValue: Int) in
            expectation.fulfill()
        }
        
        sut.observervingBlocks = [closure1, closure2]
        
        // when
        sut.informAboutNewValue(4)
        
        // then
        wait(for: [expectation], timeout: 2)
    }
    
    func test_observeUsingClosures() {
        // when
        sut.observe( { _ in } )
        sut.observe( { _ in } )
        
        // then
        XCTAssertEqual(observerMock.addObserverNumberOfCalled, 1)
        XCTAssertTrue(sut.isObserving)
        XCTAssertEqual(sut.observervingBlocks.count, 2)
    }
    
    func test_observeUsingPublisher() {
        // when
        let _ = sut.newValuePublisher
        let _ = sut.newValuePublisher
        
        // then
        XCTAssertEqual(observerMock.addObserverNumberOfCalled, 1)
        XCTAssertTrue(sut.isObserving)
        XCTAssertTrue(sut.observervingBlocks.isEmpty)
    }
    
    func test_deinitWhenObserve() {
        // given
        sut.observe( { _ in } )
        
        // when
        sut = nil
        
        // then
        XCTAssertEqual(observerMock.removeObserverNumberOfCalled, 1)
    }
    
    func test_deinitWhenNotObserve() {
        // when
        sut = nil
        
        // then
        XCTAssertEqual(observerMock.removeObserverNumberOfCalled, 0)
    }
    
    func test_handleObservedPropertyDidChangeValueCalled() {
        // given
        let subclassMock = EntityPropertySubclassMock()
        
        // when
        subclassMock.observedPropertyDidChangeValue(nil, change: nil)
        
        // then
        XCTAssertTrue(subclassMock.handleObservedPropertyDidChangeValueCalled)
    }
    
    final class EntityPropertySubclassMock: EntityProperty<Int> {
        var handleObservedPropertyDidChangeValueCalled = false
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            super.handleObservedPropertyDidChangeValue(newValue, change: change)
            
            handleObservedPropertyDidChangeValueCalled = true
        }
    }
}
