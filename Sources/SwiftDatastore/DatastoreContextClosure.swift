//
//  DatastoreContextClosure.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 20/09/2022.
//

import Foundation
import CoreData

extension SwiftDatastoreContext {
    
    public final class Closure {
        fileprivate let context: ManagedObjectContext
        
        init(context: ManagedObjectContext) {
            self.context = context
        }
    }
}

extension SwiftDatastoreContext.Closure {
    
    public var hasChanges: Bool {
        context.hasChanges
    }
    
    // MARK: Create
    public func createObject<T>() throws -> T where T: DatastoreObject {
        guard let entity = context.getEntityDescription(forName: T.entityName) else {
            throw SwiftDatastoreError.EntityNotFound(T.entityName)
        }
        
        let managedObject = context.createManagedObject(forEntity: entity)
        try context.obtainPermanentIDs(for: [managedObject])
        
        let object = T(managedObject: managedObject)
        object.objectDidCreate()
        return object
    }
    
    // MARK: Delete
    public func deleteObject<T>(_ object: T) where T: DatastoreObject {
        context.delete(object.managedObject)
    }
    
    // MARK: SaveChanges
    @discardableResult
    public func saveChanges() throws -> SwiftDatastoreSavedChanges {
        let insertedObjects = context.insertedObjects
        let updatedObjects = context.updatedObjects
        let deletedObjects = context.deletedObjects
        
        try context.save()
        
        return SwiftDatastoreSavedChanges(insertedObjects: insertedObjects,
                                          updatedObjects: updatedObjects,
                                          deletedObjects: deletedObjects)
    }
    
    // MARK: Revert Changes
    public func revertChanges() {
        context.rollback()
    }
    
    // MARK: Fetch
    public func fetch<T>(
        where: Where<T>?,
        orderBy: [OrderBy<T>] = [],
        offset: Int?,
        limit: Int?
    ) throws -> [T] where T: DatastoreObject {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: T.entityName)
        fetchRequest.predicate = `where`?.predicate
        fetchRequest.sortDescriptors = orderBy.map { $0.sortDescriptor }
        fetchRequest.fetchOffset = offset ?? fetchRequest.fetchOffset
        fetchRequest.fetchLimit = limit ?? fetchRequest.fetchLimit
        
        let objects = try context.execute(fetchRequest: fetchRequest)
        
        return objects.mapToArray()
    }
    
    // MARK: FetchFirst
    public func fetchFirst<T>(where: Where<T>? = nil,
                              orderBy: [OrderBy<T>]) throws -> T? where T: DatastoreObject {
        try fetch(where: `where`, orderBy: orderBy, offset: nil, limit: 1).first
    }
    
    // MARK: FetchProperties
    public func fetch<T>(
        _ fetchable: T.Type,
        properties: [PropetyToFetch<T>],
        where: Where<T>? = nil,
        orderBy: [OrderBy<T>]? = nil,
        offset: Int? = nil,
        limit: Int? = nil
    ) throws -> [[String: Any?]] where T: DatastoreObject {
        guard !properties.isEmpty else {
            return []
        }
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: T.entityName)
        fetchRequest.propertiesToFetch = properties.map { $0.key }
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = `where`?.predicate
        fetchRequest.sortDescriptors = orderBy?.map { $0.sortDescriptor }
        fetchRequest.fetchOffset = offset ?? fetchRequest.fetchOffset
        fetchRequest.fetchLimit = limit ?? fetchRequest.fetchLimit
        
        let values = try context.execute(fetchRequest: fetchRequest)
        
        return values.map {
            var dictionary: [String: Any] = [:]
            
            for key in $0.keys {
                let value = $0[key]
                dictionary[key] = value
            }
            
            return dictionary
        }
    }
    
    // MARK: Count
    public func count<T>(_ fetchable: T.Type, where: Where<T>?) throws -> Int where T: DatastoreObject {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: T.entityName)
        fetchRequest.predicate = `where`?.predicate
        
        let count = try context.countObjects(for: fetchRequest)
        
        return count
    }
    
    // MARK: DeleteMany
    @discardableResult
    public func deleteMany<T>(
        _ fetchable: T.Type,
        where: Where<T>
    ) throws -> Int where T: DatastoreObject {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)
        fetchRequest.predicate = `where`.predicate
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        let result = try self.context.execute(request: deleteRequest) as? NSBatchDeleteResult
        
        guard let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty else {
            return 0
        }
        
        let updated: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
        
        self.context.mergeChanges(changes: updated)
        
        return objectIDs.count
    }
    
    // MARK: UpdateMany
    @discardableResult
    public func updateMany<T>(
        _ fetchable: T.Type,
        where: Where<T>,
        propertiesToUpdate: [PropertyToUpdate<T>]
    ) throws -> Int where T: DatastoreObject {
        guard !propertiesToUpdate.isEmpty else {
            return 0
        }
        
        let request = NSBatchUpdateRequest(entityName: T.entityName)
        request.predicate = `where`.predicate
        request.resultType = .updatedObjectIDsResultType
        request.propertiesToUpdate = Dictionary(uniqueKeysWithValues: propertiesToUpdate.map { ($0.key, $0.value) })
        
        let result = try context.execute(request: request) as? NSBatchUpdateResult
        
        guard let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty else {
            return 0
        }
        
        let deleted: [AnyHashable: Any] = [NSUpdatedObjectIDsKey: objectIDs]
        
        context.mergeChanges(changes: deleted)
        
        return objectIDs.count
    }
    
    // MARK: ConvertExistingObject
    public func convert<T>(existingObject object: T) throws -> T where T: DatastoreObject {
        let managedObjectId = object.managedObject.objectID
        let managedObject = try context.existingObject(with: managedObjectId)
        return T(managedObject: managedObject)
    }
    
    // MARK: Refresh
    public func refresh(using savedChanges: SwiftDatastoreSavedChanges) {
        let objects = savedChanges.updatedObjects.union(savedChanges.deletedObjects)
        
        for object in objects {
            guard let managedObject = try? context.existingObject(with: object.objectID) else {
                Logger.log.debug("No existing object for id: \(object.objectID)")
                continue
            }
            
            context.refresh(managedObject, mergeChanges: false)
        }
    }
}

extension NSDictionary {
    var keys: [String] {
        self.allKeys.compactMap {
            $0 as? String
        }
    }
}
