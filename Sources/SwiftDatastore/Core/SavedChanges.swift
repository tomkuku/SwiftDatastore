//
//  SavedChanges.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 09/10/2022.
//

import Foundation
import CoreData

public struct SwiftDatastoreSavedChanges {
    
    let insertedObjects: Set<NSManagedObject>
    let updatedObjects: Set<NSManagedObject>
    let deletedObjects: Set<NSManagedObject>
    
    init(insertedObjects: Set<NSManagedObject>,
         updatedObjects: Set<NSManagedObject>,
         deletedObjects: Set<NSManagedObject>) {
        
        self.insertedObjects = insertedObjects
        self.updatedObjects = updatedObjects
        self.deletedObjects = deletedObjects
    }
}
