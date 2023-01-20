//
//  Entity.swift
//  SwiftDatastore
//
//  Created by Tomasz Kukułka on 16/07/2022.
//

import Foundation
import CoreData

struct EntityPropertiesContainer {
    let entityName: String
    let relationships: [(description: NSRelationshipDescription, inverse: (objectName: String, propertyName: String)?)]
}

open class DatastoreObject {
    
    // MARK: Properties
    open class var entityName: String {
        String(describing: Self.self)
    }
    
    let managedObject: NSManagedObject
    
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
    
    func createEntityDescription() -> NSEntityDescription {
        let mirrored = Mirror(reflecting: self)
        let properties: [NSPropertyDescription] = mirrored.children.compactMap {
            guard
                let childName = $0.label,
                let propertyCreatable = mirrored.descendant(childName) as? PropertyDescriptionCreatable
            else {
                return nil
            }
            
            return propertyCreatable.createPropertyDescription()
        }
        
        let entityDescription = NSEntityDescription()
        entityDescription.name = Self.entityName
        entityDescription.properties = properties
        return entityDescription
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
