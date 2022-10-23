//
//  DatastoreContextTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 12/09/2022.
//

import XCTest
import Hamcrest
import CoreData

@testable import SwiftDatastore

class DatastoreContextTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = SwiftDatastoreContext
    
    var sut: SutType!
    var managedObjectContextMock: ManagedObjectContextMock!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        managedObjectContextMock = ManagedObjectContextMock(concurrencyType: .privateQueueConcurrencyType)
        
        sut = SutType(context: managedObjectContextMock)
    }
    
    override func tearDown() {
        sut = nil
        managedObjectContextMock = nil
        super.tearDown()
    }
    
    // MARK: Perform
    func test_perform() {
        // given
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        // when
        sut.perform { context in
            expectation.fulfill()
        } success: {
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 2)
        assertThat(managedObjectContextMock.performCalled == true)
    }
    
    // MARK: Perform Completion
    func test_perform_completion() {
        // given
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        // when
        sut.perform { context in
            expectation.fulfill()
        } completion: {
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 2)
        assertThat(managedObjectContextMock.performCalled == true)
    }
}
