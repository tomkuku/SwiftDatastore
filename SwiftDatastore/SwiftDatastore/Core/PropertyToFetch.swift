//
//  PropertyToFetch.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 16/09/2022.
//

import Foundation

public struct PropetyToFetch<T> where T: DatastoreObject {
    let key: String

    public init<E>(_ keyPath: KeyPath<T, E>) where E: EntityPropertyKeyPath {
        key = keyPath.keyPathString
    }
}
