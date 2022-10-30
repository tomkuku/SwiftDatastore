//
//  ContextObserver.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 30/10/2022.
//

import Foundation
import CoreData

public final class SwiftDatastoreContextObserver {
    
    private let notitifactionCenter: NotificationCenter
    private let context: ManagedObjectContext
    
    private var updatedObservationBlocks: [(NSSet) -> Void] = []
    private var insertedObservationBlocks: [(NSSet) -> Void] = []
        
    init(notificationCenter: NotificationCenter = .default, context: ManagedObjectContext) {
        self.notitifactionCenter = notificationCenter
        self.context = context
    }
    
    private func setupAddObservers() {
        notitifactionCenter.addObserver(self,
                                        selector: #selector(contextDidChange(notification:)),
                                        name: .NSManagedObjectContextObjectsDidChange,
                                        object: context)
    }
    
    @objc private func contextDidChange(notification: Notification) {
        if let objects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            let updatedObjectsSet = NSSet(set: objects)
            
            updatedObservationBlocks.forEach {
                $0(updatedObjectsSet)
            }
        }
        
        if let objects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            let objectsSet = NSSet(set: objects)
            
            insertedObservationBlocks.forEach {
                $0(objectsSet)
            }
        }
    }
    
    public func observeUpdated<T>(_ fetchable: T.Type,
                                  where: Where<T>,
                                  block: @escaping (Set<T>) -> Void) where T: DatastoreObject {
        let predicate = `where`.predicate
        
        let observationBlock = { (objects: NSSet) in
            guard let filteredObjects = objects.filtered(using: predicate) as? Set<NSManagedObject> else {
                Logger.log.error("Sorted set is nil")
                return
            }
            
            
            let objects = filteredObjects.map {
                T.create(from: $0)
            }
            
            block(Set(objects))
        }
        
        updatedObservationBlocks.append(observationBlock)
    }
    
    public func observeInserted<T>(_ fetchable: T.Type,
                                   where: Where<T>,
                                   block: @escaping (Set<T>) -> Void) where T: DatastoreObject {
        let predicate = `where`.predicate
        
        let observationBlock = { (objects: NSSet) in
            guard let filteredObjects = objects.filtered(using: predicate) as? Set<NSManagedObject> else {
                Logger.log.error("Sorted set is nil")
                return
            }
            
            let objects = filteredObjects.map {
                T.create(from: $0)
            }
            
            block(Set(objects))
        }
        
        insertedObservationBlocks.append(observationBlock)
    }
}
