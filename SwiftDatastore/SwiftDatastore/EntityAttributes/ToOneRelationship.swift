//
//  ToOneRelationship.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import CoreData

public enum Relationship {
        
    @propertyWrapper
    public final class ToOne<T>: EntityProperty<T?>, EntityPropertyKeyPath where T: DatastoreObject {
        
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
        
        public override init() {
            // Public init
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            var object: T?
            
            if let managedObject = newValue as? NSManagedObject {
                object = T(managedObject: managedObject)
            }
            
            informAboutNewValue(object)
        }
    }
}
