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
    public final class ToMany<T>: EntityProperty<Set<T>>, EntityPropertyKeyPath where T: DatastoreObject {
        
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
                let objects = newValue.map { $0.managedObject }
                
                managedObject.willChangeValue(forKey: key,
                                              withSetMutation: .set,
                                              using: [])
                
                set.removeAllObjects()
                
                objects.forEach {
                    set.add($0)
                }
                
                managedObject.didChangeValue(forKey: key,
                                             withSetMutation: .set,
                                             using: Set(objects))
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
                let objects: Set<T> = changedManagedObjects.mapToSet()
                
                changedManagedObjects.removeAll()
                
                informAboutNewValue(objects)
                
            case .insertion, .removal:
                guard
                    let newValues = newValue as? Set<NSManagedObject>,
                    newValues.count == 1,
                    let firstValue = newValues.first
                else {
                    return
                }
                changedManagedObjects.insert(firstValue)
                
            default:
                break
            }
        }
    }
}
