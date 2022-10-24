//
//  ManagedObjectObserverTests.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 04/10/2022.
//

import XCTest
import CoreData

@testable import SwiftDatastore

class ManagedObjectObserverTests: XCTestCase {

    var sut: ManagedObjectObserver!
    
    // MARK: Tests
    func test_observe_without_changeKind() {
        // given
        let expectation = XCTestExpectation()
        
        let delegateClient = TestDelegateClient()
        delegateClient.expectation = expectation
                
        let managedObjectWrapperMock = ManagedObjectWrapperMock()
        
        sut = ManagedObjectObserver(managedObjectWrapper: managedObjectWrapperMock)
        sut.addObserver(forKey: "aaa", delegate: delegateClient)
        
        let change: [NSKeyValueChangeKey: Any] = [.newKey: 1, .oldKey: 2]
        
        // when
        sut.observeValue(forKeyPath: "aaa",
                         of: nil,
                         change: change,
                         context: nil)
        
        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertNil(delegateClient._change)
        XCTAssertTrue(managedObjectWrapperMock.addObserverCalled)
        
        let gotValue = delegateClient._newValue as? Int
        XCTAssertEqual(gotValue, 1)
    }
    
    func test_observe_with_changeKind() {
        // given
        let expectation = XCTestExpectation()
        
        let delegateClient = TestDelegateClient()
        delegateClient.expectation = expectation
                
        let managedObjectWrapperMock = ManagedObjectWrapperMock()
        
        sut = ManagedObjectObserver(managedObjectWrapper: managedObjectWrapperMock)
        sut.addObserver(forKey: "aaa", delegate: delegateClient)
        
        let change: [NSKeyValueChangeKey: Any] = [.newKey: 1,
                                                  .oldKey: 2,
                                                  .kindKey: NSKeyValueChange.insertion]
        
        // when
        sut.observeValue(forKeyPath: "aaa",
                         of: nil,
                         change: change,
                         context: nil)
        
        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertNil(delegateClient._change)
        XCTAssertTrue(managedObjectWrapperMock.addObserverCalled)
        
        let gotValue = delegateClient._newValue as? Int
        XCTAssertEqual(gotValue, 1)
    }
    
    func test_removeObserver() {
        // given
        let managedObjectWrapperMock = ManagedObjectWrapperMock()
        sut = ManagedObjectObserver(managedObjectWrapper: managedObjectWrapperMock)
        
        // when
        sut.removeObserver(forKey: "aaa")
        
        // then
        XCTAssertTrue(managedObjectWrapperMock.removeObserverCalled)
    }
    
    func test_removeObserver_while_deinit() {
        // given
        let delegateClient = TestDelegateClient()
        
        let managedObjectWrapperMock = ManagedObjectWrapperMock()
        sut = ManagedObjectObserver(managedObjectWrapper: managedObjectWrapperMock)
        
        sut.addObserver(forKey: "aaa", delegate: delegateClient)
        
        // when
        sut = nil
        
        // then
        XCTAssertTrue(managedObjectWrapperMock.removeObserverCalled)
    }
    
    // MARK: TestDelegateClient
    private class TestDelegateClient: ManagedObjectObserverDelegate {
        var _newValue: Any?
        var _change: NSKeyValueChange?
        var expectation: XCTestExpectation!
        
        func observedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            _newValue = newValue
            _change = change
            expectation.fulfill()
        }
    }
}
