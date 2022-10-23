//
//  FetchedResultsControllerMock.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 09/08/2022.
//

import Foundation
import CoreData

@testable import SwiftDatastore

final class FetchedResultsControllerMock: FetchedResultsController {
    var _sections: [NSFetchedResultsSectionInfo]?
    var _indexPath: IndexPath!
    var _predicateFormat: String?
    var _sortDescriptors: [NSSortDescriptor]?
    var _sectionNameKeyPath: String?
    
    var objectAtIndexPathCalled = false
    var performFetchCalled = false
    
    override var sections: [NSFetchedResultsSectionInfo]? {
        _sections
    }
    
    override func object(at indexPath: IndexPath) -> NSManagedObject {
        objectAtIndexPathCalled = true
        _indexPath = indexPath
        return PersistentStoreCoordinatorMock.shared.managedObject
    }
    
    override func performFetch() throws {
        performFetchCalled = true
    }
    
    override func create(fetchRequest: NSFetchRequest<NSManagedObject>,
                         context: NSManagedObjectContext,
                         sectionNameKeyPath: String?) {
        _predicateFormat = fetchRequest.predicate?.predicateFormat
        _sortDescriptors = fetchRequest.sortDescriptors
        _sectionNameKeyPath = sectionNameKeyPath
    }
}
