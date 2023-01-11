//
//  OptionalAttribute.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import Combine
import CoreData

typealias OptionalAttributeType = EntityPropertyKeyPath & EntityPropertyValueType & PropertyDescriptionCreatable

extension Attribute {
 
    @propertyWrapper
    public final class Optional<T>: EntityProperty<T?>, OptionalAttributeType where T: AttributeValueType {
        // swiftlint:disable nesting
        public typealias KeyPathType = T
        public typealias ValueType = T
        // swiftlint:enable nesting
        
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
        
        func createPropertyDescription() -> NSPropertyDescription {
            let attribute = NSAttributeDescription()
            attribute.isOptional = true
            attribute.attributeType = T.attributeType
            attribute.name = key
            return attribute
        }
    }
}
