//
//  ManagedObjectContextProviderTests.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 10/10/2022.
//

import Foundation
import XCTest
import CoreData

@testable import SwiftDatastore

class ManagedObjectContextProviderTests: XCTestCase {
    
    var sut: ManagedObjectContextProvider!
    var fileManagerMock: FileManagerMock!
    var pocMock: PersistentStoreCoordinatorMock!
    
    let storeName = "store_name"
    let storeURL = URL(string: "file:///Test/")!
    
    lazy var expectedStoreURL = storeURL.appendingPathComponent(storeName).appendingPathExtension("sqlite")
    
    override func setUpWithError() throws {
        super.setUp()
        fileManagerMock = FileManagerMock()
        fileManagerMock._url = storeURL
        
        sut = try ManagedObjectContextProvider(persistentStoreCoordinatorType: PersistentStoreCoordinatorMock.self,
                                               managedObjectModel: NSManagedObjectModel(),
                                               storeName: storeName,
                                               fileManager: fileManagerMock)
        
        pocMock = sut.poc as? PersistentStoreCoordinatorMock
    }
    
    override func tearDown() {
        fileManagerMock = nil
        sut = nil
        pocMock = nil
        super.tearDown()
    }
    
    // MARK: Tests
    func test_create() {
        // then
        XCTAssertFalse(pocMock.destroyPersistentStoreCalled)
        XCTAssertTrue(pocMock.addPersistentStoreCalled)
        XCTAssertEqual(pocMock._addStoreURL, expectedStoreURL)
        XCTAssertEqual(pocMock._addStoreType, NSSQLiteStoreType)
    }
    
    func test_create_with_destoryStoreDuringCreating() throws {
        // when
        sut = try ManagedObjectContextProvider(persistentStoreCoordinatorType: PersistentStoreCoordinatorMock.self,
                                               managedObjectModel: NSManagedObjectModel(),
                                               storeName: storeName,
                                               destoryStoreDuringCreating: true,
                                               fileManager: fileManagerMock)

        
        pocMock = sut.poc as? PersistentStoreCoordinatorMock
        
        // then
        XCTAssertTrue(pocMock.destroyPersistentStoreCalled)
        XCTAssertEqual(pocMock._destroyStoreURL, expectedStoreURL)
        XCTAssertEqual(pocMock._destroyStoreType, NSSQLiteStoreType)
        XCTAssertTrue(pocMock.addPersistentStoreCalled)
    }
    
    func test_get_mainContext() {
        // when
        let context = sut.viewContext
        
        // then
        XCTAssertEqual(context.concurrencyType, .mainQueueConcurrencyType)
        XCTAssertEqual(context.persistentStoreCoordinator, pocMock)
    }
    
    func test_createNewPrivateContext() {
        // when
        let context = sut.createNewPrivateContext()
        
        // then
        XCTAssertEqual(context.concurrencyType, .privateQueueConcurrencyType)
        XCTAssertEqual(context.persistentStoreCoordinator, pocMock)
    }
    
    // MARK: FileManagerMock
    class FileManagerMock: FileManager {
        var _url: URL!
        
        override func urls(for directory: FileManager.SearchPathDirectory,
                           in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
            [_url]
        }
    }
    
    // MARK: PersistentStoreCoordinatorMock
    final class PersistentStoreCoordinatorMock: NSPersistentStoreCoordinator {
        var _addStoreType: String!
        var _addStoreURL: URL!
        var _destroyStoreType: String!
        var _destroyStoreURL: URL!
        
        var addPersistentStoreCalled = false
        var destroyPersistentStoreCalled = false
        
        override func addPersistentStore(ofType storeType: String,
                                         configurationName configuration: String?,
                                         at storeURL: URL?,
                                         options: [AnyHashable: Any]? = nil) throws -> NSPersistentStore {
            addPersistentStoreCalled = true
            _addStoreType = storeType
            _addStoreURL = storeURL
            return NSPersistentStore(persistentStoreCoordinator: nil,
                                     configurationName: nil,
                                     at: URL(string: "https://www.apple.com")!)
        }
        
        override func destroyPersistentStore(at url: URL,
                                             ofType storeType: String,
                                             options: [AnyHashable: Any]? = nil) throws {
            _destroyStoreType = storeType
            _destroyStoreURL = url
            destroyPersistentStoreCalled = true
        }
    }
}
