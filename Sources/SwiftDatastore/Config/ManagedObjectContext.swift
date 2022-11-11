//
//  ManagedObjectContext.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import Foundation
import CoreData

public class ManagedObjectContext: NSManagedObjectContext {
    func getEntityDescription(forName entityName: String) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: entityName, in: self)
    }
    
    func createManagedObject(forEntity entity: NSEntityDescription) -> NSManagedObject {
        NSManagedObject(entity: entity, insertInto: self)
    }
    
    func execute<T: NSFetchRequestResult>(fetchRequest: NSFetchRequest<T>) throws -> [T] {
        try fetch(fetchRequest)
    }
    
    func countObjects<T: NSFetchRequestResult>(for request: NSFetchRequest<T>) throws -> Int {
        try count(for: request)
    }
    
    func mergeChanges(changes: [AnyHashable: Any]) {
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
    
    @discardableResult
    func execute(request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
        try execute(request)
    }
}
