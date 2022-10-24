//
//  ViewContext.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 19/09/2022.
//

import Foundation
import CoreData

public final class SwiftDatastoreViewContext {
    
    // MARK: Propertes
    let context: ManagedObjectContext
    
    init(context: ManagedObjectContext) {
        self.context = context
    }
    
    // MARK: Fetch
    public func fetch<T>(
        where: Where<T>? = nil,
        orderBy: [OrderBy<T>] = [],
        offset: Int? = nil,
        limit: Int? = nil
    ) throws -> [T] where T: DatastoreObject {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: T.entityName)
        fetchRequest.predicate = `where`?.predicate
        fetchRequest.sortDescriptors = orderBy.map { $0.sortDescriptor }
        fetchRequest.fetchOffset = offset ?? fetchRequest.fetchOffset
        fetchRequest.fetchLimit = limit ?? fetchRequest.fetchLimit
        
        let objects = try context.execute(fetchRequest: fetchRequest)
        
        return objects.map {
            T.create(from: $0)
        }
    }
    
    // MARK: FetchFirst
    public func fetchFirst<T>(where: Where<T>? = nil, orderBy: [OrderBy<T>]) throws -> T? where T: DatastoreObject {
        try fetch(where: `where`, orderBy: orderBy, offset: 0, limit: 1).first
    }
    
    // MARK: Count
    public func count<T>(
        _ fetchable: T.Type,
        where: Where<T>?
    ) throws -> Int where T: DatastoreObject {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: T.entityName)
        fetchRequest.predicate = `where`?.predicate
        
        let count = try context.countObjects(for: fetchRequest)
        
        return count
    }
}
