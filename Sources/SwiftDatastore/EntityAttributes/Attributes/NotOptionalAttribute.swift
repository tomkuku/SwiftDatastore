//
//  NotOptionalAttribute.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import CoreData

extension Attribute {
    
    @propertyWrapper
    public final class NotOptional<T>: EntityProperty<T> where T: AttributeValueType {
        // MARK: Properties
        public var wrappedValue: T {
            get {
                getManagedObjectValueForKey().unsafelyUnwrapped
            }
            set {
                setManagedObjectValueForKey(value: newValue)
            }
        }
        
        public var projectedValue: NotOptional<T> {
            self
        }
        
        override public init() {
            // Public init
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            guard let newValue = newValue as? T else {
                Logger.log.error("observedPropertyDidChangeValue a new value is nil!")
                return
            }
            
            informAboutNewValue(newValue)
        }
    }
}

// MARK: EntityPropertyKeyPath
extension Attribute.NotOptional: EntityPropertyKeyPath {
    public typealias KeyPathType = T
}

// MARK: EntityPropertyValueType
extension Attribute.NotOptional: EntityPropertyValueType {
    public typealias ValueType = T
}

// MARK: PropertyDescriptionCreatable
extension Attribute.NotOptional: PropertyDescriptionCreatable {
    func createPropertyDescription() -> NSPropertyDescription {
        let attribute = NSAttributeDescription()
        attribute.isOptional = false
        attribute.attributeType = T.attributeType
        attribute.name = key
        return attribute
    }
}
