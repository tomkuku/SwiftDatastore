//
//  ToOne.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import CoreData

public protocol EntityRelationship {
    var relationshipDescription: NSRelationshipDescription? { get }
    var inverseRelationshipDescription: NSRelationshipDescription? { get }
    
    func createRelationshipDescription() -> NSRelationshipDescription
}

public enum Relationship {
        
    @propertyWrapper
    public final class ToOne<T>: EntityProperty<T?>, EntityPropertyKeyPath, EntityRelationship where T: DatastoreObject {
        
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
        
        public init(_ name: String) {
            super.init()
            self.key = name
        }
        
        public private(set) var relationshipDescription: NSRelationshipDescription?
        public private(set) var inverseRelationshipDescription: NSRelationshipDescription?
        
        public init<V>(_ name: String, inverse: KeyPath<T, V>) where V: EntityRelationship {
            super.init()
            self.key = name
            
            let relationshipObject: V = {
                let entityDescription = NSEntityDescription(name: "-")
                let managedObject = NSManagedObject(entity: entityDescription, insertInto: nil)
                let datastoreObject = T(managedObject: managedObject)
                return datastoreObject[keyPath: inverse]
            }()
            
            // Sets lacked values in relationshipDescription in inverse object.
            let inverseRelationship = relationshipObject.createRelationshipDescription()
            
            // Creates relationshipDescription in current.
            let relationship = NSRelationshipDescription()
            relationship.name = key
            relationship.destinationEntity = T.entityDescription
            relationship.inverseRelationship = inverseRelationship
            relationship.minCount = 0
            relationship.maxCount = 1
            
            inverseRelationship.inverseRelationship = relationship
            
            // Appends new relationships into entityDescriptions in `EntityProprties` objects.
            relationshipDescription = relationship
            inverseRelationshipDescription = inverseRelationship
            T.entityDescription.properties.append(inverseRelationship)
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            var object: T?
            
            if let managedObject = newValue as? NSManagedObject {
                object = T(managedObject: managedObject)
            }
            
            informAboutNewValue(object)
        }
        
        // Creates relationshipDescription to use in init(name:, inverse: ).
        public func createRelationshipDescription() -> NSRelationshipDescription {
            let relationshipDescription = NSRelationshipDescription()
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
