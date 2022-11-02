//
//  Entity.swift
//  SwiftDatastore
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
    
    internal let managedObject: NSManagedObject
    
    private let managedObjectObserver: ManagedObjectObserverLogic
    
    public private(set) lazy var objectID: DatastoreObjectID = {
        DatastoreObjectID(managedObjectID: managedObject.objectID)
    }()
    
    // MARK: Init
    public required init(managedObject: NSManagedObject) {
        self.managedObject = managedObject
        self.managedObjectObserver = ManagedObjectObserver(managedObject: managedObject)
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
            
            attribute.managedObject = self.managedObject
            attribute.managedObjectObserver = self.managedObjectObserver
            
            if attribute.key == "" {
                attribute.key = String(childName.dropFirst()) // delete '_' prefix
            }
        }
    }
}

// MARK: Hashable
extension DatastoreObject: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(managedObject.objectID)
    }
    
    public static func == (lhs: DatastoreObject, rhs: DatastoreObject) -> Bool {
        lhs.managedObject.objectID == rhs.managedObject.objectID
    }
}
