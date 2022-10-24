//
//  OptionalAttribute.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 01/08/2022.
//

import Foundation
import Combine

extension Attribute {
 
    @propertyWrapper
    public final class Optional<T>: EntityProperty<T?>, EntityPropertyKeyPath {
        
        // swiftlint:disable:next nesting
        public typealias KeyPathType = T
        
        // MARK: Properties
        public var wrappedValue: T? {
            get {
                managedObjectWrapper.getValue(forKey: key)
            }
            set {
                managedObjectWrapper.set(newValue, forKey: key)
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
