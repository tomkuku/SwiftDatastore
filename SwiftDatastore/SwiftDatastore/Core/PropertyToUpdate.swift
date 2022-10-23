//
//  PropertyToUpdate.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 08/09/2022.
//

import Foundation

public struct PropertyToUpdate<T> where T: DatastoreObject {
    let key: String
    let value: Any
    
    public init<V>(_ keyPath: KeyPath<T, V>, _ value: V.KeyPathType) where V: EntityPropertyKeyPath {
        self.key = keyPath.keyPathString
        self.value = value
    }
}
