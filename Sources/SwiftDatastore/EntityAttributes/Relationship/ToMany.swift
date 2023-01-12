//
//  ToMany.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import CoreData

extension Relationship {
    
    @propertyWrapper
    public final class ToMany<T>: EntityProperty<Set<T>>, RelationshipProperty where T: DatastoreObject {
        
        // swiftlint:disable:next nesting
        public typealias KeyPathType = T
        
        // MARK: Properties
        public var wrappedValue: Set<T> {
            get {
                defer {
                    managedObject.didAccessValue(forKey: key)
                }
                
                managedObject.willAccessValue(forKey: key)
                
                guard
                    let managedObjects = managedObject.mutableSetValue(forKey: key).allObjects as? [NSManagedObject]
                else {
                    Logger.log.debug("No managedObjects.")
                    return []
                }
                
                return managedObjects.mapToSet()
            }
            set {
                let set = managedObject.mutableSetValue(forKey: key)
                let newObjects = newValue.map { $0.managedObject }
                
                managedObject.willChangeValue(forKey: key,
                                              withSetMutation: .set,
                                              using: [])
                
                set.removeAllObjects()
                set.addObjects(from: newObjects)
                
                managedObject.didChangeValue(forKey: key,
                                             withSetMutation: .set,
                                             using: Set(newObjects))
            }
        }
        
        public var projectedValue: ToMany<T> {
            self
        }
        
        private var changedManagedObjects: Set<NSManagedObject> = []
        private var invsereObjectName: String?
        private var inversePropertyName: String?
        
        public override init() {
            // Public init
        }
        
        public init<V>(inverse: KeyPath<T, V>) where V: RelationshipProperty {
            super.init()
            self.invsereObjectName = T.entityName
            self.inversePropertyName = inverse.keyPathString
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            guard let changeKind = change else {
                return
            }
            
            switch changeKind {
            case .replacement:
                let objects: Set<T> = changedManagedObjects.mapToSet()
                
                informAboutNewValue(objects)
                
            default:
                guard let objects = newValue as? Set<NSManagedObject> else {
                    Logger.log.error("No new values as a set of NSManagedObject")
                    return
                }
                
                changedManagedObjects = objects
            }
        }
    }
}

// MARK: PropertyDescriptionCreatable
extension Relationship.ToMany: PropertyDescriptionCreatable {
    func createPropertyDescription() -> NSPropertyDescription {
        let relationshipDescription: NSRelationshipDescription = {
            guard let invsereObjectName, let inversePropertyName else {
                return NSRelationshipDescription()
            }
            
            return InverseRelationshipDescription(invsereObjectName: invsereObjectName,
                                                  inversePropertyName: inversePropertyName)
        }()
        
        relationshipDescription.name = key
        relationshipDescription.minCount = 0
        relationshipDescription.maxCount = 0
        relationshipDescription.isOptional = false
        relationshipDescription.isOrdered = false
        return relationshipDescription
    }
}
