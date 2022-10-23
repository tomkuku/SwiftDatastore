//
//  PocController.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 10/10/2022.
//

import Foundation
import CoreData

class PocController {
    var poc: NSPersistentStoreCoordinator?
    
    func create(with model: NSManagedObjectModel) {
        poc = NSPersistentStoreCoordinator(managedObjectModel: model)
    }
    
    @discardableResult
    func addPersistentStore(ofType storeType: String,
                            configurationName configuration: String? = nil,
                            at storeURL: URL?,
                            options: [AnyHashable: Any]? = nil) throws -> NSPersistentStore {
        guard let poc = poc else {
            fatalError("PersistentStoreCoordinator is nil")
        }
        
        return try poc.addPersistentStore(ofType: storeType,
                                    configurationName: configuration,
                                    at: storeURL,
                                    options: options)
    }
    
    func destroyPersistentStore(at url: URL,
                                ofType storeType: String,
                                options: [AnyHashable: Any]? = nil) throws {
        guard let poc = poc else {
            fatalError("PersistentStoreCoordinator is nil")
        }
        
        try poc.destroyPersistentStore(at: url, ofType: storeType, options: options)
    }
}
