//
//  DatastoreObjectIDTests.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 30/10/2022.
//

import XCTest
import CoreData

@testable import SwiftDatastore

final class DatastoreObjectIDTests: XCTestCase {
    
    func test_description() {
        // given
        let managedObjectIDMock = ManagedObjectIDMock()
        managedObjectIDMock._description = "test-description"
        
        // when
        let sut = DatastoreObjectID(managedObjectID: managedObjectIDMock)
        
        // then
        XCTAssertEqual(sut.description, managedObjectIDMock._description)
    }
    
    func test_equatable_equal() {
        // given
        let managedObjectID = NSManagedObjectID()
        
        // when
        let sut1 = DatastoreObjectID(managedObjectID: managedObjectID)
        let sut2 = DatastoreObjectID(managedObjectID: managedObjectID)
        
        // then
        XCTAssertEqual(sut1, sut2)
    }
    
    func test_equatable_notEqual() {
        // given
        let sut1 = DatastoreObjectID(managedObjectID: NSManagedObjectID())
        let sut2 = DatastoreObjectID(managedObjectID: NSManagedObjectID())
        
        // then
        XCTAssertNotEqual(sut1, sut2)
    }
    
    class ManagedObjectIDMock: NSManagedObjectID {
        var _description: String!
        
        override var description: String {
            _description
        }
    }
}
