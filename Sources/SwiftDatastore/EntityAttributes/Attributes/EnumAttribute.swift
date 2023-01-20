//
//  EnumAttribute.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import CoreData

extension Attribute {
        
    @propertyWrapper
    public final class Enum<T>: EntityProperty<T?> where T: RawRepresentable, T.RawValue: AttributeValueType {
        // MARK: Properties
        public var wrappedValue: T? {
            get {
                guard let rawValue: T.RawValue = getManagedObjectValueForKey() else {
                    Logger.log.debug("RawValue is nil.")
                    return nil
                }
                return T.init(rawValue: rawValue)
            }
            set {
                setManagedObjectValueForKey(value: newValue?.rawValue)
            }
        }
        
        public var projectedValue: Enum<T> {
            self
        }
           
        public override init() {
            // Public init
        }
        
        override func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
            var value: T?
            
            if let rawValue = newValue as? T.RawValue {
                value = T(rawValue: rawValue)
            }
            
            informAboutNewValue(value)
        }
    }
}

// MARK: EntityPropertyKeyPath
extension Attribute.Enum: EntityPropertyKeyPath {
    public typealias KeyPathType = T
}

// MARK: PropertyDescriptionCreatable
extension Attribute.Enum: PropertyDescriptionCreatable {
    func createPropertyDescription() -> NSPropertyDescription {
        let attribute = NSAttributeDescription()
        attribute.isOptional = true
        attribute.attributeType = T.RawValue.attributeType
        attribute.name = key
        return attribute
    }
}
