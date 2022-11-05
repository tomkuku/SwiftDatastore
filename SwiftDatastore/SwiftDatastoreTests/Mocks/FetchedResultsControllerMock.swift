//
//  FetchedResultsControllerMock.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 09/08/2022.
//

import Foundation
import CoreData

@testable import SwiftDatastore

final class FetchedResultsControllerMock: NSFetchedResultsController<NSManagedObject> {
    var _sections: [NSFetchedResultsSectionInfo]?
    var _indexPath: IndexPath!
    
    var objectAtIndexPathCalled = false
    var performFetchCalled = false
    
    override var sections: [NSFetchedResultsSectionInfo]? {
        _sections
    }
    
    override func performFetch() throws {
        performFetchCalled = true
    }
    
    override func object(at indexPath: IndexPath) -> NSManagedObject {
        objectAtIndexPathCalled = true
        return PersistentStoreCoordinatorMock.shared.managedObject
    }
}
