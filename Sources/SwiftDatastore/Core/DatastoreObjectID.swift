//
//  DatastoreObjectID.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 30/10/2022.
//

import Foundation
import CoreData

public struct DatastoreObjectID: CustomStringConvertible {
    private let managedObjectID: NSManagedObjectID
    
    public var description: String {
        managedObjectID.description
    }
    
    init(managedObjectID: NSManagedObjectID) {
        self.managedObjectID = managedObjectID
    }
}

extension DatastoreObjectID: Equatable {
    public static func == (lhs: DatastoreObjectID, rhs: DatastoreObjectID) -> Bool {
        lhs.managedObjectID == rhs.managedObjectID
    }
}
