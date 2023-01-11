//
//  EnumAttribute.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import CoreData

typealias EnumAttributeType = EntityPropertyKeyPath & PropertyDescriptionCreatable

extension Attribute {
        
    @propertyWrapper
    public final class Enum<T>: EntityProperty<T?>, EnumAttributeType where T: RawRepresentable, T.RawValue: AttributeValueType {
        
        // swiftlint:disable:next nesting
        public typealias KeyPathType = T
        
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
        
        func createPropertyDescription() -> NSPropertyDescription {
            let attribute = NSAttributeDescription()
            attribute.isOptional = true
            attribute.attributeType = T.RawValue.attributeType
            attribute.name = key
            return attribute
        }
    }
}
