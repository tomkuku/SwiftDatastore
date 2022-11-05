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
    var bundleMock: BundleMock!
    var momControllerMock: MomControllerMock!
    var pocMock: PersistentStoreCoordinatorMock!
    
    let modelName = "model_name"
    let storeName = "store_name"
    let storeURL = URL(string: "file:///Test/")!
    
    lazy var expectedStoreURL = storeURL.appendingPathComponent(storeName).appendingPathExtension("sqlite")
    
    override func setUpWithError() throws {
        super.setUp()
        momControllerMock = MomControllerMock()
        bundleMock = BundleMock()
        fileManagerMock = FileManagerMock()
        fileManagerMock._url = storeURL
        
        sut = try ManagedObjectContextProvider(
            persistentStoreCoordinatorType: PersistentStoreCoordinatorMock.self,
            storeName: storeName,
            managedObjectModelName: modelName,
            fileManager: fileManagerMock,
            bundle: bundleMock,
            momController: momControllerMock)
        
        pocMock = sut.poc as? PersistentStoreCoordinatorMock
    }
    
    override func tearDown() {
        momControllerMock = nil
        bundleMock = nil
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
        sut = try ManagedObjectContextProvider(
            persistentStoreCoordinatorType: PersistentStoreCoordinatorMock.self,
            storeName: storeName,
            managedObjectModelName: modelName,
            destoryStoreDuringCreating: true,
            fileManager: fileManagerMock,
            bundle: bundleMock,
            momController: momControllerMock)
        
        pocMock = sut.poc as? PersistentStoreCoordinatorMock
        
        // then
        XCTAssertEqual(bundleMock._resourceName, modelName)
        XCTAssertEqual(bundleMock._extension, "momd")
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
    
    // MARK: BundleMock
    class BundleMock: Bundle {
        var _resourceName: String!
        var _extension: String!
        
        override func url(forResource name: String?, withExtension ext: String?) -> URL? {
            _resourceName = name
            _extension = ext
            
            return URL(string: "https://www.apple.com")!
        }
    }
    
    // MARK: FileManagerMock
    class FileManagerMock: FileManager {
        var _url: URL!
        
        override func urls(for directory: FileManager.SearchPathDirectory,
                           in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
            [_url]
        }
    }
    
    // MARK: MomControllerMock
    class MomControllerMock: MomController {
        override func createModel(contentsOf url: URL) -> NSManagedObjectModel? {
            NSManagedObjectModel()
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
