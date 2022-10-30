//
//  Entity.swift
//  DatabaseApi
//
//  Created by Tomasz Kukułka on 16/07/2022.
//

import Foundation
import CoreData

open class DatastoreObject {
    
    // MARK: Properties
    open class var entityName: String {
        String(describing: Self.self)
    }
    
    internal let managedObjectWrapper: ManagedObjectWrapperLogic
    
    private let managedObjectObserver: ManagedObjectObserverLogic
    
    public private(set) lazy var objectID: DatastoreObjectID = {
        DatastoreObjectID(managedObjectID: managedObjectWrapper.object.objectID)
    }()
    
    // MARK: Init
    public required init(managedObjectWrapper: ManagedObjectWrapperLogic) {
        self.managedObjectWrapper = managedObjectWrapper
        managedObjectObserver = ManagedObjectObserver(managedObjectWrapper: managedObjectWrapper)
        config()
    }
    
    // MARK: Public
    open func objectDidCreate() {
    }
    
    // MARK: Private
    private func config() {
        let mirrored = Mirror(reflecting: self)
        for child in mirrored.children {
            guard
                let childName = child.label,
                let attribute = mirrored.descendant(childName) as? EntityPropertyLogic
            else {
                continue
            }
            
            attribute.managedObjectWrapper = self.managedObjectWrapper
            attribute.managedObjectObserver = self.managedObjectObserver
            
            if attribute.key == "" {
                attribute.key = String(childName.dropFirst()) // delete '_' prefix
            }
        }
    }
}

extension DatastoreObject {
    static func create(from managedObject: NSManagedObject) -> Self {
        let managedObjectWrapper = ManagedObjectWrapper(managedObject: managedObject)
        return .init(managedObjectWrapper: managedObjectWrapper)
    }
}

// MARK: Hashable
extension DatastoreObject: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(managedObjectWrapper.object.objectID)
    }
    
    public static func == (lhs: DatastoreObject, rhs: DatastoreObject) -> Bool {
        lhs.managedObjectWrapper.object.objectID == rhs.managedObjectWrapper.object.objectID
    }
}
