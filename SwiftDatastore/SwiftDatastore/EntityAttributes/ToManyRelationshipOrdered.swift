//
//  ToManyRelationshipOrdered.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 26/10/2022.
//

import Foundation
import CoreData

extension Relationship.ToMany {
    
    @propertyWrapper
    public final class Ordered<T>: EntityProperty<Array<T>>, EntityPropertyKeyPath where T: DatastoreObject {
        
        // swiftlint:disable:next nesting
        public typealias KeyPathType = T

        // MARK: Properties
        public var wrappedValue: [T] {
            get {
                defer {
                    managedObjectWrapper.object.didAccessValue(forKey: key)
                }
                
                managedObjectWrapper.object.willAccessValue(forKey: key)
                
                guard
                    let managedObjects = managedObjectWrapper.mutableSetValue(forKey: key).allObjects as? [NSManagedObject]
                else {
                    Logger.log.error("allObjects is nil")
                    return []
                }
                
                let sortedObjects = sort(managedObjects)
                
                return sortedObjects.map {
                    T.create(from: $0)
                }
            }
            set {
                let set = managedObjectWrapper.mutableSetValue(forKey: key)
                let objects = newValue.map { $0.managedObjectWrapper.object }
                let newSet = Set(objects)
                
                managedObjectWrapper.object.willChangeValue(forKey: key,
                                                            withSetMutation: .set,
                                                            using: [])
                
                set.removeAllObjects()
                
                newValue.forEach {
                    set.add($0.managedObjectWrapper.object)
                }
                
                managedObjectWrapper.object.didChangeValue(forKey: key,
                                                           withSetMutation: .set,
                                                           using: newSet)
            }
        }
        
        public var projectedValue: Ordered<T> {
            self
        }
        
        private var changedManagedObjects: [NSManagedObject] = []
        
        public override init() {
            // public init
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            guard let changeKind = change else {
                return
            }
            
            switch changeKind {
            case .replacement:
                let sortedObjects = sort(changedManagedObjects)
                
                let objects = sortedObjects.map {
                    T.create(from: $0)
                }
                
                changedManagedObjects.removeAll()
                
                informAboutNewValue(objects)
                
            case .insertion, .removal:
                if let newValues = newValue as? Set<NSManagedObject>,
                   newValues.count == 1,
                   let firstValue = newValues.first {
                    changedManagedObjects.append(firstValue)
                }
            default:
                break
            }
        }
    }
}
