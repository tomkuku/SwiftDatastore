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
    }
    
    // MARK: Properties
    private(set) lazy var viewContext: ManagedObjectContext = {
        let moc = ManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = poc
        moc.automaticallyMergesChangesFromParent = true
        return moc
    }()
    
    let poc: NSPersistentStoreCoordinator // Internal access for tests
    
    init<T>(managedObjectModel: NSManagedObjectModel,
            storeName: String,
            destoryStoreDuringCreating: Bool,
            fileManager: FileManager = .default,
            persistentStoreCoordinatorType: T.Type = NSPersistentStoreCoordinator.self
    ) throws where T: NSPersistentStoreCoordinator {        
        let storeURL = Self.createPersistentStoreURL(fileManager: fileManager, storeFileName: storeName)
        
        self.poc = persistentStoreCoordinatorType.init(managedObjectModel: managedObjectModel)
        
        try setupPoc(destroyPersistentStore: destoryStoreDuringCreating, storeURL: storeURL)
    }
    
    public func createNewPrivateContext() -> ManagedObjectContext {
        let moc = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = poc
        moc.automaticallyMergesChangesFromParent = true
        return moc
    }
    
    // MARK: Private
    private static func createPersistentStoreURL(fileManager: FileManager, storeFileName: String) -> URL {
        var storeUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        storeUrl.appendPathComponent(storeFileName)
        storeUrl.appendPathExtension(Constant.sqliteFileExtension)
        return storeUrl
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
