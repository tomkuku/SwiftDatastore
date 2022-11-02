//
//  FetchedObjectsController.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 08/08/2022.
//

import Foundation
import CoreData
import Combine

public enum FetchedObjectsChangeType<T> where T: DatastoreObject {
    case inserted(T, IndexPath)
    case updated(T, IndexPath)
    case deleted(IndexPath)
    case moved(T, IndexPath, IndexPath)
}

public final class FetchedObjectsController<T> where T: DatastoreObject {
    
    typealias ChangesPassthroughSubjectType = PassthroughSubject<FetchedObjectsChangeType<T>, Never>
    
    // MARK: Properties
    private let fetchedResultsController: FetchedResultsController?
    private let changesPassthroughSubject = ChangesPassthroughSubjectType()
    
    private var changeBlocks: [(FetchedObjectsChangeType<T>) -> Void] = []
    
    public lazy var changesPublisher: AnyPublisher<FetchedObjectsChangeType<T>, Never> = {
        changesPassthroughSubject.eraseToAnyPublisher()
    }()
    
    internal init(fetchedResultsController: FetchedResultsController,
                  context: NSManagedObjectContext,
                  predicate: NSPredicate?,
                  sortDescriptors: [NSSortDescriptor],
                  sectionNameKeyPath: String?) {
        self.fetchedResultsController = fetchedResultsController
        
        guard !sortDescriptors.isEmpty else {
            Logger.log.fatal("SortDescriptors mustn't be empty!")
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: T.entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        self.fetchedResultsController?.create(fetchRequest: fetchRequest,
                                              context: context,
                                              sectionNameKeyPath: sectionNameKeyPath)
        self.fetchedResultsController?.delegate = self
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension FetchedObjectsController: FetchedResultsControllerDelegate {
    func controller(didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard let managedObject = anObject as? NSManagedObject else {
            Logger.log.error("anObject is not NSManagedObejct")
            return
        }
        
        let object = T(managedObject: managedObject)
        var change: FetchedObjectsChangeType<T>?
        
        switch (type, indexPath, newIndexPath) {
        case (.insert, .none, .some(let insertedIndexPath)):
            change = .inserted(object, insertedIndexPath)
            
        case (.delete, .some(let deletedIndexPath), .none):
            change = .deleted(deletedIndexPath)
            
        case (.update, .some(let updatedIndexPath), _):
            change = .updated(object, updatedIndexPath)
            
        case (.move, .some(let fromIndexPath), .some(let toIndexPath)):
            change = .moved(object, fromIndexPath, toIndexPath)
            
        default:
            // swiftlint:disable:next line_length
            Logger.log.debug("No action when newIndexPath: \(newIndexPath?.string ?? "nil"), indexPath: \(indexPath?.string ?? "nil")")
            return
        }
        
        guard let change = change else {
            return
        }
        
        changesPassthroughSubject.send(change)
        
        changeBlocks.forEach {
            $0(change)
        }
    }
}

extension FetchedObjectsController {
    
    // MARK: NumberOfSections
    public var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    // MARK: init
    public convenience init<V>(viewContext: SwiftDatastoreViewContext,
                               where: Where<T>? = nil,
                               orderBy: [OrderBy<T>],
                               groupBy: KeyPath<T, V>?) where V: EntityPropertyKeyPath {
        self.init(fetchedResultsController: FetchedResultsController(),
                  context: viewContext.context,
                  predicate: `where`?.predicate,
                  sortDescriptors: orderBy.map { $0.sortDescriptor },
                  sectionNameKeyPath: groupBy?.keyPathString)
    }
    
    // MARK: PerformFetch
    public func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            Logger.log.error("Performing fetch failed with error: \(error.localizedDescription)!")
        }
    }
    
    // MARK: SectionName
    public func sectionName(inSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
    
    // MARK: NumberOfObjectsInSection
    public func numberOfObjects(inSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    // MARK: GetObjectAtIndexPath
    public func getObject(at indexPath: IndexPath) -> T {
        guard let managedObject = fetchedResultsController?.object(at: indexPath) else {
            Logger.log.fatal("No object at indexPath: \(indexPath)!")
        }
        return T(managedObject: managedObject)
    }
    
    // MARK: ObserveChanges
    public func observeChanges(_ block: @escaping (FetchedObjectsChangeType<T>) -> Void) {
        changeBlocks.append(block)
    }
}
