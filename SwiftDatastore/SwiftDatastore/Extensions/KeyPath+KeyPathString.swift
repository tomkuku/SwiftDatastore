//
//  AnyKeyPath+keyPathString.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 17/08/2022.
//

import Foundation

extension KeyPath where Root: DatastoreObject, Value: EntityPropertyKeyPath {
    var keyPathString: String {
        let object = Root.init(managedObjectWrapper: ManagedObjectWrapper())
        return object[keyPath: self].key
    }
}
