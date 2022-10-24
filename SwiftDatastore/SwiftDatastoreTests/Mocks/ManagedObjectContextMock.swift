//
//  ManagedObjectContextMock.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 16/07/2022.
//

import Foundation
import CoreData

@testable import SwiftDatastore

enum TestError: Error {
    case test
}

class ManagedObjectContextMock: ManagedObjectContext {
    var _hasChanges: Bool = false
    var _fetchRequestResult: [NSFetchRequestResult]!
    var _propertiesToFetch: [String]?
    var _fetchLimit: Int = -1
    var _fetchOffset: Int = -1
    var _predicate: NSPredicate? = nil
    var _sorts: [NSSortDescriptor]? = nil
    var _numberOfObjectsToCount = 0
    var _batchDeleteRequestResultType: NSBatchDeleteRequestResultType?
    var _batchUpdateRequestResultType: NSBatchUpdateRequestResultType?
    var _objectIDsToMerge: [NSManagedObjectID]?
    var _batchDeleteResultMock: BatchDeleteResultMock!
    var _batchUpdateResultMock: BatchUpdateRequestMock!
    var _batchUpdateRequestPropertiesToUpdate: [AnyHashable: Any]?
    var _insertedObjects: Set<NSManagedObject> = []
    var _updatedObjects: Set<NSManagedObject> = []
    var _deletedObjects: Set<NSManagedObject> = []
    
    var getEntityDescriptionCalled = false
    var createManagedObjectCalled = false
    var saveCalled = false
    var hasChangesCalled = false
    var deleteCalled = false
    var countObjectsCalled = false
    var mergeChangesCalled = false
    var executeRequestCalled = false
    var performCalled = false
    var performAndWaitCalled = false
    var rollbackCalled = false
    var objectWithObjectIDCalled = false
    var executeFetchRequestCalled = false
    var existingObjectCalled = false
    var refreshCalled = false
    var obtainPermanentIDsCalled = false
    
    convenience init() {
        self.init(concurrencyType: .mainQueueConcurrencyType)
    }
    
    override var hasChanges: Bool {
        hasChangesCalled = true
        return _hasChanges
    }
    
    override var insertedObjects: Set<NSManagedObject> {
        _insertedObjects
    }
    
    override var updatedObjects: Set<NSManagedObject> {
        _updatedObjects
    }
    
    override var deletedObjects: Set<NSManagedObject> {
        _deletedObjects
    }
    
    override func obtainPermanentIDs(for objects: [NSManagedObject]) throws {
        obtainPermanentIDsCalled = true
    }
    
    override func getEntityDescription(forName entityName: String) -> NSEntityDescription? {
        getEntityDescriptionCalled = true
        return NSEntityDescription()
    }
    
    override func createManagedObject(forEntity entity: NSEntityDescription) -> NSManagedObject {
        createManagedObjectCalled = true
        return NSManagedObject(entity: PersistentStoreCoordinatorMock.shared.entityDescription,
                               insertInto: self)
    }
    
    override func save() throws {
        saveCalled = true
    }
    
    override func delete(_ object: NSManagedObject) {
        deleteCalled = true
    }
        
    override func execute<T: NSFetchRequestResult>(fetchRequest: NSFetchRequest<T>) throws -> [T] {
        executeFetchRequestCalled = true
        _predicate = fetchRequest.predicate
        _sorts = fetchRequest.sortDescriptors
        _fetchOffset = fetchRequest.fetchOffset
        _fetchLimit = fetchRequest.fetchLimit
        _propertiesToFetch = fetchRequest.propertiesToFetch as? [String]
        
        return _fetchRequestResult as? [T] ?? []
    }
    
    override func countObjects<T: NSFetchRequestResult>(for request: NSFetchRequest<T>) throws -> Int {
        _predicate = request.predicate
        _sorts = request.sortDescriptors
        countObjectsCalled = true
        return _numberOfObjectsToCount
    }
    
    @discardableResult
    override func execute(request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
        executeRequestCalled = true
        
        if let batchDeleteRequest = request as? NSBatchDeleteRequest {
            _predicate = batchDeleteRequest.fetchRequest.predicate
            _batchDeleteRequestResultType = batchDeleteRequest.resultType
            
            return _batchDeleteResultMock
        }
        else if let batchUpdateRequest = request as? NSBatchUpdateRequest {
            _predicate = batchUpdateRequest.predicate
            _batchUpdateRequestResultType = batchUpdateRequest.resultType
            _batchUpdateRequestPropertiesToUpdate = batchUpdateRequest.propertiesToUpdate
            
            return _batchUpdateResultMock
        }
        else if let asynchronousFetchRequest = request as? NSAsynchronousFetchRequest<NSManagedObject> {
            _predicate = asynchronousFetchRequest.fetchRequest.predicate
            _sorts = asynchronousFetchRequest.fetchRequest.sortDescriptors
        }
        
        return NSPersistentStoreResult()
    }
    
    override func mergeChanges(changes: [AnyHashable: Any]) {
        mergeChangesCalled = true
        
        if let deletedObjectIDs = changes[NSDeletedObjectsKey] as? [NSManagedObjectID] {
            _objectIDsToMerge = deletedObjectIDs
        } else if let updatedObjectIDs = changes[NSUpdatedObjectIDsKey] as? [NSManagedObjectID] {
            _objectIDsToMerge = updatedObjectIDs
        }
    }
    
    override func perform(_ block: @escaping () -> Void) {
        super.perform {
            self.performCalled = true
            block()
        }
    }

    override func performAndWait(_ block: () -> Void) {
        super.performAndWait {
            self.performAndWaitCalled = true
            block()
        }
    }
    
    override func rollback() {
        rollbackCalled = true
    }
    
    override func existingObject(with objectID: NSManagedObjectID) throws -> NSManagedObject {
        existingObjectCalled = true
        return NSManagedObject(entity: PersistentStoreCoordinatorMock.shared.entityDescription,
                               insertInto: self)
    }
    
    override func refresh(_ object: NSManagedObject, mergeChanges flag: Bool) {
        refreshCalled = true
    }
}
