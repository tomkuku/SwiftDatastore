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
        static let sqliteStoreType = NSSQLiteStoreType
        static let sqliteFileExtension = "sqlite"
        static let managedObjectModelExtension = "momd"
    }
    
    // MARK: Properties
    private(set) lazy var viewContext: ManagedObjectContext = {
        let moc = ManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = poc
        moc.automaticallyMergesChangesFromParent = true
        return moc
    }()
    
    var poc: NSPersistentStoreCoordinator
    
    init(storeName: String,
         managedObjectModelName: String,
         destoryStoreDuringCreating: Bool = false,
         fileManager: FileManager = .default,
         bundle: Bundle = .main,
         momController: MomController = MomController()
    ) throws {
        let mom = try Self.createManagedObjectModel(momController: momController,
                                                bundle: bundle,
                                                modelFileName: managedObjectModelName)
        
        let storeURL = Self.createPersistentStoreURL(fileManager: fileManager, storeName: storeName)
        
        self.poc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        try setupPoc(destroyPersistentStore: destoryStoreDuringCreating, storeURL: storeURL)
    }
    
    public func createNewPrivateContext() -> ManagedObjectContext {
        let moc = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = poc
        moc.automaticallyMergesChangesFromParent = true
        return moc
    }
    
    // MARK: Private
    private static func createManagedObjectModel(momController: MomController,
                                                 bundle: Bundle,
                                                 modelFileName: String) throws -> NSManagedObjectModel {
        guard
            let url = bundle.url(forResource: modelFileName,
                                 withExtension: Constant.managedObjectModelExtension),
            let mom = momController.createModel(contentsOf: url)
        else {
            throw SwiftDatastoreError.managedObjectModelNotFound
        }
        
        return mom
    }
    
    private static func createPersistentStoreURL(fileManager: FileManager, storeName: String) -> URL {
        let storeFileName = "\(storeName).\(Constant.sqliteFileExtension)"
        let documentsDirectoryUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectoryUrl.appendingPathComponent(storeFileName)
    }
    
    private func setupPoc(destroyPersistentStore: Bool, storeURL: URL) throws {
        if destroyPersistentStore {
            try poc.destroyPersistentStore(at: storeURL, ofType: Constant.sqliteStoreType)
            
            Logger.log.debug("PersistentStore was destroyed.")
        }
        
        try poc.addPersistentStore(ofType: Constant.sqliteStoreType,
                                   configurationName: nil,
                                   at: storeURL)
        
        Logger.log.debug("PersistentStore was added.")
    }
}
