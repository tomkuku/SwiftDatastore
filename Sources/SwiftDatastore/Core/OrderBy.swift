//
//  OrderBy.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 15/08/2022.
//

import Foundation
import CoreData

public struct OrderBy<T> where T: DatastoreObject {
    let sortDescriptor: NSSortDescriptor

    init<V>(keyPath: KeyPath<T, V>, ascending: Bool) where V: EntityPropertyKeyPath {
        sortDescriptor = NSSortDescriptor(key: keyPath.keyPathString, ascending: ascending)
    }
    
    public static func asc<V>(_ keyPath: KeyPath<T, V>) -> Self where V: EntityPropertyKeyPath {
        Self.init(keyPath: keyPath, ascending: true)
    }
    
    public static func desc<V>(_ keyPath: KeyPath<T, V>) -> Self where V: EntityPropertyKeyPath {
        Self.init(keyPath: keyPath, ascending: false)
    }
}
