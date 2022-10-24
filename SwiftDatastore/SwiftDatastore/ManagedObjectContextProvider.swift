//
//  ManagedObjectContextProvider.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 18/07/2022.
//

import Foundation
import CoreData

final class ManagedObjectContextProvider {
    private enum Constant {
        static let storeType = NSSQLiteStoreType
        static let storeExtension = "sqlite"
        static let managedObjectModelExtension = "momd"
    }
    
    // MARK: Properties
    private(set) lazy var viewContext: ManagedObjectContext = {
        let moc = ManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = pocController.poc
        moc.automaticallyMergesChangesFromParent = true
        return moc
    }()
    
    private let storeName: String
    private let managedObjectModelName: String
    private let fileManager: FileManager
    private let budle: Bundle
    private let momController: MomController
    private let pocController: PocController
    
    init(
        storeName: String,
        managedObjectModelName: String,
        destoryStoreDuringCreating: Bool = false,
        fileManager: FileManager = .default,
        budle: Bundle = .main,
        momController: MomController = MomController(),
        pocController: PocController = PocController()
    ) throws {
        self.storeName = storeName
        self.managedObjectModelName = managedObjectModelName
        self.fileManager = fileManager
        self.budle = budle
        self.momController = momController
        self.pocController = pocController
        
        let model = try createManagedObjectModel()
        let persistentStoreURL = createPersistentStoreURL()
        
        try setupPoc(managedObjectModel: model,
                     persistentStoreURL: persistentStoreURL,
                     destroyPersistentStore: destoryStoreDuringCreating)
    }
    
    public func createNewPrivateContext() -> ManagedObjectContext {
        let moc = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = pocController.poc
        moc.automaticallyMergesChangesFromParent = true
        return moc
    }
    
    // MARK: Private
    private func createManagedObjectModel() throws -> NSManagedObjectModel {
        let resourceName = managedObjectModelName
        let `extension` = Constant.managedObjectModelExtension
        
        guard
            let url = budle.url(forResource: resourceName, withExtension: `extension`),
            let mom = momController.createModel(contentsOf: url)
        else {
            throw SwiftDatastoreError.entityNotFound
        }
        
        return mom
    }
    
    private func createPersistentStoreURL() -> URL {
        let storeFileName = "\(storeName).\(Constant.storeExtension)"
        let documentsDirectoryUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectoryUrl.appendingPathComponent(storeFileName)
    }
    
    private func setupPoc(managedObjectModel: NSManagedObjectModel,
                          persistentStoreURL: URL,
                          destroyPersistentStore: Bool) throws {
        pocController.create(with: managedObjectModel)
        
        if destroyPersistentStore {
            try pocController.destroyPersistentStore(at: persistentStoreURL,
                                           ofType: Constant.storeType)
            Logger.log.debug("PersistentStore was destroyed.")
        }
        
        try pocController.addPersistentStore(ofType: Constant.storeType,
                                   at: persistentStoreURL)
        Logger.log.debug("PersistentStore was added.")
    }
}
