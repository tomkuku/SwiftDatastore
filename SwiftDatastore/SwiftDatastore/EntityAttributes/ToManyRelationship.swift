//
//  ToManyRelationship.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import CoreData

extension Relationship {
    
    @propertyWrapper
    public final class ToMany<T>: EntityProperty<Set<T>>, EntityPropertyKeyPath where T: DatastoreObject {
        
        // swiftlint:disable:next nesting
        public typealias KeyPathType = T

        // MARK: Properties
        public var wrappedValue: Set<T> {
            get {
                defer {
                    managedObjectWrapper.object.didAccessValue(forKey: key)
                }
                
                managedObjectWrapper.object.willAccessValue(forKey: key)
                
                guard
                    let managedObjects = managedObjectWrapper.mutableSetValue(forKey: key).allObjects as? [NSManagedObject]
                else {
                    Logger.log.debug("No managedObjects.")
                    return []
                }
                
                return Set(managedObjects.map {
                    T.create(from: $0)
                })
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
        
        public var projectedValue: ToMany<T> {
            self
        }
        
        private var changedManagedObjects: Set<NSManagedObject> = []
        
        public override init() {
            // Public init
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            guard let changeKind = change else {
                return
            }
            
            switch changeKind {
            case .replacement:
                let objects = Set(changedManagedObjects.map {
                    T.create(from: $0)
                })
                
                changedManagedObjects.removeAll()
                
                informAboutNewValue(objects)
                
            case .insertion, .removal:
                if let newValues = newValue as? Set<NSManagedObject>,
                   newValues.count == 1,
                   let firstValue = newValues.first {
                    changedManagedObjects.insert(firstValue)
                }
            default:
                break
            }
        }
    }
}
