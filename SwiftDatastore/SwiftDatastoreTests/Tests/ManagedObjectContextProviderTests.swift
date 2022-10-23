//
//  ManagedObjectContextProviderTests.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 10/10/2022.
//

import Foundation
import XCTest
import CoreData
import Hamcrest

@testable import SwiftDatastore

class ManagedObjectContextProviderTests: XCTestCase {
        
    var sut: ManagedObjectContextProvider!
    var fileManagerMock: FileManagerMock!
    var bundleMock: BundleMock!
    var momControllerMock: MomControllerMock!
    var pocControllerMock: PocControllerMock!
    
    override func setUp() {
        fileManagerMock = FileManagerMock()
        bundleMock = BundleMock()
        momControllerMock = MomControllerMock()
        pocControllerMock = PocControllerMock()
    }
    
    // MARK: Tests
    func test_create() throws {
        // when
        sut = try ManagedObjectContextProvider(storeName: "store-name",
                                               managedObjectModelName: "model-name",
                                               destoryStoreDuringCreating: false,
                                               fileManager: fileManagerMock,
                                               budle: bundleMock,
                                               momController: momControllerMock,
                                               pocController: pocControllerMock)
        
        // then
        XCTAssertTrue(pocControllerMock.createCalled)
        XCTAssertFalse(pocControllerMock.destroyPersistentStoreCalled)
        XCTAssertTrue(pocControllerMock.addPersistentStoreCalled)
    }
    
    func test_create_with_destoryStoreDuringCreating() throws {
        // when
        sut = try ManagedObjectContextProvider(storeName: "store-name",
                                               managedObjectModelName: "model-name",
                                               destoryStoreDuringCreating: true,
                                               fileManager: fileManagerMock,
                                               budle: bundleMock,
                                               momController: momControllerMock,
                                               pocController: pocControllerMock)
        
        // then
        XCTAssertTrue(pocControllerMock.createCalled)
        XCTAssertTrue(pocControllerMock.destroyPersistentStoreCalled)
        XCTAssertTrue(pocControllerMock.addPersistentStoreCalled)
    }
    
    func test_get_mainContext() throws {
        // given
        sut = try ManagedObjectContextProvider(storeName: "store-name",
                                               managedObjectModelName: "model-name",
                                               destoryStoreDuringCreating: true,
                                               fileManager: fileManagerMock,
                                               budle: bundleMock,
                                               momController: momControllerMock,
                                               pocController: pocControllerMock)
        
        // when
        let context = sut.viewContext
        
        // then
        XCTAssertEqual(context.concurrencyType, .mainQueueConcurrencyType)
        XCTAssertEqual(context.persistentStoreCoordinator, pocControllerMock.poc)
        XCTAssertTrue(pocControllerMock.createCalled)
        XCTAssertTrue(pocControllerMock.destroyPersistentStoreCalled)
        XCTAssertTrue(pocControllerMock.addPersistentStoreCalled)
    }
    
    func test_createNewPrivateContext() throws {
        // given
        sut = try ManagedObjectContextProvider(storeName: "store-name",
                                               managedObjectModelName: "model-name",
                                               destoryStoreDuringCreating: true,
                                               fileManager: fileManagerMock,
                                               budle: bundleMock,
                                               momController: momControllerMock,
                                               pocController: pocControllerMock)
        
        // when
        let context = sut.createNewPrivateContext()
        
        // then
        XCTAssertEqual(context.concurrencyType, .privateQueueConcurrencyType)
        XCTAssertEqual(context.persistentStoreCoordinator, pocControllerMock.poc)
        XCTAssertTrue(pocControllerMock.createCalled)
        XCTAssertTrue(pocControllerMock.destroyPersistentStoreCalled)
        XCTAssertTrue(pocControllerMock.addPersistentStoreCalled)
    }
    
    // MARK: BundleMock
    class BundleMock: Bundle {
        override func url(forResource name: String?, withExtension ext: String?) -> URL? {
            URL(string: "https://www.apple.com")!
        }
    }
    
    // MARK: FileManagerMock
    class FileManagerMock: FileManager {
        override func urls(for directory: FileManager.SearchPathDirectory,
                  in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
            [URL(string: "https://www.apple.com")!]
        }
    }
    
    // MARK: MomControllerMock
    class MomControllerMock: MomController {
        override func createModel(contentsOf url: URL) -> NSManagedObjectModel? {
            NSManagedObjectModel()
        }
    }
    
    // MARK: PocControllerMock
    class PocControllerMock: PocController {
        var createCalled = false
        var destroyPersistentStoreCalled = false
        var addPersistentStoreCalled = false
        
        override func create(with model: NSManagedObjectModel) {
            createCalled = true
        }
        
        override func destroyPersistentStore(at url: URL,
                                             ofType storeType: String,
                                             options: [AnyHashable: Any]? = nil) throws {
            destroyPersistentStoreCalled = true
        }
        
        override func addPersistentStore(ofType storeType: String,
                                         configurationName configuration: String? = nil,
                                         at storeURL: URL?,
                                         options: [AnyHashable : Any]? = nil) throws -> NSPersistentStore {
            addPersistentStoreCalled = true
            return NSPersistentStore(persistentStoreCoordinator: nil,
                                     configurationName: nil,
                                     at: URL(string: "https://www.apple.com")!)
        }
    }
}
