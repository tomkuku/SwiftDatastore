//
//  ToManyOrdered.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 26/10/2022.
//

import Foundation
import CoreData

extension Relationship.ToMany {
    
    @propertyWrapper
    public final class Ordered<T>: EntityProperty<Array<T>>, RelationshipProperty where T: DatastoreObject {
        
        // swiftlint:disable:next nesting
        public typealias KeyPathType = T

        // MARK: Properties
        public var wrappedValue: [T] {
            get {
                defer {
                    managedObject.didAccessValue(forKey: key)
                }
                
                managedObject.willAccessValue(forKey: key)
                
                guard
                    let managedObjects = managedObject.mutableOrderedSetValue(forKey: key).array as? [NSManagedObject]
                else {
                    Logger.log.debug("array is nil")
                    return []
                }
                
                return managedObjects.mapToArray()
            }
            set {
                let orderedSet = managedObject.mutableOrderedSetValue(forKey: key)
                let newObjects = newValue.map { $0.managedObject }

                managedObject.willChange(.setting,
                                         valuesAt: IndexSet(),
                                         forKey: key)
                
                orderedSet.removeAllObjects()
                orderedSet.addObjects(from: newObjects)
                
                managedObject.didChange(.setting,
                                        valuesAt: orderedSet.arrayIndexSet,
                                        forKey: key)
            }
        }
        
        public var projectedValue: Ordered<T> {
            self
        }
        
        private var changedManagedObjects: [NSManagedObject] = []
        private var invsereObjectName: String?
        private var inversePropertyName: String?
        
        public override init() {
            // public init
        }
        
        public init<V>(inverse: KeyPath<T, V>) where V: RelationshipProperty {
            super.init()
            self.invsereObjectName = T.entityName
            self.inversePropertyName = inverse.keyPathString
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            guard let changeKind = change else {
                Logger.log.error("No change kind")
                return
            }
            
            switch changeKind {
            case .setting:
                let objects: [T] = changedManagedObjects.mapToArray()
                
                informAboutNewValue(objects)
                
            default:
                guard let objects = newValue as? [NSManagedObject] else {
                    Logger.log.error("No new values as an array of NSManagedObject")
                    return
                }
                
                changedManagedObjects = objects
            }
        }
    }
}

// MARK: PropertyDescriptionCreatable
extension Relationship.ToMany.Ordered: PropertyDescriptionCreatable {
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
        relationshipDescription.isOrdered = true
        return relationshipDescription
    }
}

fileprivate extension NSOrderedSet {
    var arrayIndexSet: IndexSet {
        IndexSet(integersIn: array.startIndex..<array.endIndex)
    }
}
