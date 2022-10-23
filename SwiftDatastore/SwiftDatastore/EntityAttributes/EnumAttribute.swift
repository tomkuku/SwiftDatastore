//
//  EnumAttribute.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation

extension Attribute {
    
    @propertyWrapper
    public final class Enum<T: RawRepresentable>: EntityProperty<T?>, EntityPropertyKeyPath {
        
        public typealias KeyPathType = T

        // MARK: Properties
        public var wrappedValue: T? {
            get {
                guard let rawValue: T.RawValue = managedObjectWrapper.getValue(forKey: key) else {
                    Logger.log.debug("RawValue is nil.")
                    return nil
                }
                return T.init(rawValue: rawValue)
            } set {
                managedObjectWrapper.set(newValue?.rawValue, forKey: key)
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
