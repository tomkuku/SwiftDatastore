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
    
    let managedObject: NSManagedObject
    
    static var entityDescription = NSEntityDescription(name: entityName)
    
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
    
    func createEntityDescription() {
        let mirrored = Mirror(reflecting: self)
        mirrored.children.forEach {
            guard
                let childName = $0.label,
                let entityRelationship = mirrored.descendant(childName) as? EntityRelationship
            else {
                return
            }
            
            guard
                let relationshipDescription = entityRelationship.relationshipDescription,
                let inverseRelationshipDescription = entityRelationship.inverseRelationshipDescription
            else {
                // Object without inverse
                return
            }
            
            inverseRelationshipDescription.destinationEntity = Self.entityDescription
            Self.entityDescription.properties.append(relationshipDescription)
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
