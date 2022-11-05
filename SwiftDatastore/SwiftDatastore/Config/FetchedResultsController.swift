//
//  FetchedResultsController.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 08/08/2022.
//

import Foundation
import CoreData

final class FetchedResultsControllerHandler: NSObject, NSFetchedResultsControllerDelegate {
    var changeClosure: ((Any, IndexPath?, NSFetchedResultsChangeType, IndexPath?) -> Void)?
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        changeClosure?(anObject, indexPath, type, newIndexPath)
    }
}
