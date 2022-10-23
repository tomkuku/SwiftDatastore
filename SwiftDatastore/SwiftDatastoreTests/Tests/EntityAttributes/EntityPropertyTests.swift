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
    
    var managedObjectWrapperMock: ManagedObjectWrapperMock!
    var observerMock: ManagedObjectObserverMock!
    var cancellable: Set<AnyCancellable> = []
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        managedObjectWrapperMock = ManagedObjectWrapperMock()
        observerMock = ManagedObjectObserverMock()
        
        sut = SutType()
        sut.managedObjectWrapper = managedObjectWrapperMock
        sut.managedObjectObserver = observerMock
    }
    
    override func tearDown() {
        sut = nil
        managedObjectWrapperMock = nil
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
    
    func test_observe_usingClosures() {
        // when
        sut.observe( { _ in } )
        sut.observe( { _ in } )
        
        // then
        XCTAssertEqual(observerMock.addObserverNumberOfCalled, 1)
        XCTAssertTrue(sut.isObserving)
        XCTAssertEqual(sut.observervingBlocks.count, 2)
    }
    
    func test_observe_usingPublisher() {
        // when
        let _ = sut.newValuePublisher
        let _ = sut.newValuePublisher
        
        // then
        XCTAssertEqual(observerMock.addObserverNumberOfCalled, 1)
        XCTAssertTrue(sut.isObserving)
        XCTAssertTrue(sut.observervingBlocks.isEmpty)
    }
    
    func test_deinit_whenObserve() {
        // given
        sut.observe( { _ in } )

        // when
        sut = nil

        // then
        XCTAssertEqual(observerMock.removeObserverNumberOfCalled, 1)
    }

    func test_deinit_whenNotObserve() {
        // when
        sut = nil

        // then
        XCTAssertEqual(observerMock.removeObserverNumberOfCalled, 0)
    }
}
