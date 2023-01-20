//
//  OptionalAttribute.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import Combine
import CoreData

extension Attribute {
 
    @propertyWrapper
    public final class Optional<T>: EntityProperty<T?> where T: AttributeValueType {
        // MARK: Properties
        public var wrappedValue: T? {
            get {
                getManagedObjectValueForKey()
            }
            set {
                setManagedObjectValueForKey(value: newValue)
            }
        }
        
        public var projectedValue: Attribute.Optional<T> {
            self
        }
        
        public override init() {
            // Public init
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            let value = newValue as? T
            
            informAboutNewValue(value)
        }
    }
}

// MARK: EntityPropertyKeyPath
extension Attribute.Optional: EntityPropertyKeyPath {
    public typealias KeyPathType = T
}

// MARK: EntityPropertyValueType
extension Attribute.Optional: EntityPropertyValueType {
    public typealias ValueType = T
}

// MARK: PropertyDescriptionCreatable
extension Attribute.Optional: PropertyDescriptionCreatable {
    func createPropertyDescription() -> NSPropertyDescription {
        let attribute = NSAttributeDescription()
        attribute.isOptional = true
        attribute.attributeType = T.attributeType
        attribute.name = key
        return attribute
    }
}
