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
        
        public typealias KeyPathType = T

        // MARK: Properties        
        public var wrappedValue: T? {
            get {
                guard let managedObject: NSManagedObject = managedObjectWrapper.getValue(forKey: key) else {
                    Logger.log.debug("ManagedObject is nil.")
                    return nil
                }
                return T.create(from: managedObject)
            }
            set {
                managedObjectWrapper.set(newValue?.managedObjectWrapper.object, forKey: key)
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
                object = T.create(from: managedObject)
            }
            
            informAboutNewValue(object)
        }
    }
}
