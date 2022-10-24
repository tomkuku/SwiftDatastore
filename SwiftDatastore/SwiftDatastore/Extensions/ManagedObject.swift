//
//  ManagedObject.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import Foundation
import CoreData

extension NSManagedObject {
    public func getValue<T>(forKey key: String) -> T? {
        defer {
            didAccessValue(forKey: key)
        }
        willAccessValue(forKey: key)
        return primitiveValue(forKey: key) as? T
    }
    
    public func set(_ value: Any?, forKey key: String) {
        defer {
            didChangeValue(forKey: key)
        }
        willChangeValue(forKey: key)
        guard let value = value else {
            setPrimitiveValue(nil, forKey: key)
            return
        }
        setPrimitiveValue(value, forKey: key)
    }
}
