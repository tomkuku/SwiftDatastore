//
//  Set+DatastoreInit.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 31/10/2022.
//

import Foundation
import CoreData

extension Sequence where Element: NSManagedObject {
    func mapToSet<T>() -> Set<T> where T: DatastoreObject {
        Set(map {
            T(managedObject: $0)
        })
    }
    
    func mapToArray<T>() -> [T] where T: DatastoreObject {
        map {
            T(managedObject: $0)
        }
    }
}
