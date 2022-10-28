//
//  NotOptionalAttribute.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation

public enum Attribute {
    
    @propertyWrapper
    public final class NotOptional<T>: EntityProperty<T>, EntityPropertyKeyPath, EntityPropertyValueType {
        
        // swiftlint:disable nesting
        public typealias KeyPathType = T
        public typealias ValueType = T
        // swiftlint:enable nesting
        
        // MARK: Properties
        public var wrappedValue: T {
            get {
                managedObjectWrapper.getValue(forKey: key).unsafelyUnwrapped
            }
            set {
                managedObjectWrapper.set(newValue, forKey: key)
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
                print("observedPropertyDidChangeValue a new value is nil!")
                return
            }
            
            informAboutNewValue(newValue)
        }
    }
}
