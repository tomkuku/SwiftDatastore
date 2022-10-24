//
//  FetchedResultsController.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 08/08/2022.
//

import Foundation
import CoreData

protocol FetchedResultsControllerDelegate: AnyObject {
    func controller(didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?)
}

class FetchedResultsController: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    private var fetchedResultsController: NSFetchedResultsController<NSManagedObject>!
    
    var sections: [NSFetchedResultsSectionInfo]? {
        fetchedResultsController.sections
    }
    
    weak var delegate: FetchedResultsControllerDelegate?
    
    func create(fetchRequest: NSFetchRequest<NSManagedObject>,
                context: NSManagedObjectContext,
                sectionNameKeyPath: String?) {
        fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        fetchedResultsController.delegate = self
    }
    
    func object(at indexPath: IndexPath) -> NSManagedObject {
        fetchedResultsController.object(at: indexPath)
    }
    
    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        delegate?.controller(didChange: anObject,
                             at: indexPath,
                             for: type,
                             newIndexPath: newIndexPath)
    }
}
