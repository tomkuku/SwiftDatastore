//
//  AnyKeyPath+keyPathString.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 17/08/2022.
//

import Foundation
import CoreData

extension KeyPath where Root: DatastoreObject, Value: EntityPropertyKeyPath {
    var keyPathString: String {
        let entityDescription = NSEntityDescription()
        entityDescription.name = "-"
        
        let managedObject = NSManagedObject(entity: entityDescription, insertInto: nil)
        
        let object = Root(managedObject: managedObject)
        return object[keyPath: self].key
    }
}
