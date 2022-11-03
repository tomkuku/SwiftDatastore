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
    public final class Ordered<T>: EntityProperty<Array<T>>, EntityPropertyKeyPath where T: DatastoreObject {
        
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
                                         valuesAt: orderedSet.arrayIndexSet,
                                         forKey: key)
                
                orderedSet.removeAllObjects()
                
                newObjects.forEach {
                    orderedSet.add($0)
                }
                
                managedObject.didChange(.setting,
                                        valuesAt: orderedSet.arrayIndexSet,
                                        forKey: key)
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
                Logger.log.error("No change kind")
                return
            }
            
            switch changeKind {
            case .setting:
                let objects: [T] = changedManagedObjects.mapToArray()
                
                changedManagedObjects.removeAll()
                
                informAboutNewValue(objects)
                
            default:
                guard
                    let newValues = newValue as? [NSManagedObject],
                    newValues.count == 1,
                    let firstValue = newValues.first
                else {
                    Logger.log.error("newValue: \(String(describing: newValue)) is not array with size equal to 1")
                    return
                }
                changedManagedObjects.append(firstValue)
            }
        }
    }
}

fileprivate extension NSOrderedSet {
    var arrayIndexSet: IndexSet {
        IndexSet(integersIn: array.startIndex..<array.endIndex)
    }
}
