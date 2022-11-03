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
        
        public override init() {
            // public init
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            guard let changeKind = change else {
                return
            }
            
//            switch changeKind {
//            case .replacement:
//                let sortedObjects = sort(changedManagedObjects)
//                
//                let objects = sortedObjects.map {
//                    T.create(from: $0)
//                }
//                
//                changedManagedObjects.removeAll()
//                
//                informAboutNewValue(objects)
//                
//            case .insertion, .removal:
//                if let newValues = newValue as? Set<NSManagedObject>,
//                   newValues.count == 1,
//                   let firstValue = newValues.first {
//                    changedManagedObjects.append(firstValue)
//                }
//            default:
//                break
//            }
        }
    }
}

fileprivate extension NSOrderedSet {
    var arrayIndexSet: IndexSet {
        IndexSet(integersIn: array.startIndex..<array.endIndex)
    }
}
