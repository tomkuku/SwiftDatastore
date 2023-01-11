//
//  ToOne.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import CoreData

public enum Relationship {
    
    @propertyWrapper
    public final class ToOne<T>: EntityProperty<T?>, EntityRelationshipType where T: DatastoreObject {
        
        // swiftlint:disable:next nesting
        public typealias KeyPathType = T
        
        // MARK: Properties
        public var wrappedValue: T? {
            get {
                guard let managedObject: NSManagedObject = getManagedObjectValueForKey() else {
                    Logger.log.debug("ManagedObject is nil.")
                    return nil
                }
                return T(managedObject: managedObject)
            }
            set {
                setManagedObjectValueForKey(value: newValue?.managedObject)
            }
        }
        
        public var projectedValue: ToOne<T> {
            self
        }
        
        private var invsereObjectName: String?
        private var inversePropertyName: String?
        
        override public init() {
            // public init
        }
        
        public init<V>(inverse: KeyPath<T, V>) where V: RelationshipProperty {
            super.init()
            self.invsereObjectName = T.entityName
            self.inversePropertyName = inverse.keyPathString
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            var object: T?
            
            if let managedObject = newValue as? NSManagedObject {
                object = T(managedObject: managedObject)
            }
            
            informAboutNewValue(object)
        }
        
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
            relationshipDescription.maxCount = 1
            return relationshipDescription
        }
    }
}

extension NSEntityDescription {
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
