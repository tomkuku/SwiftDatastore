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

typealias FetchedResultsController1 = NSFetchedResultsController<NSManagedObject>

public final class FetchedObjectsController<T> where T: DatastoreObject {
    
    typealias ChangesPassthroughSubjectType = PassthroughSubject<FetchedObjectsChangeType<T>, Never>
    
    // MARK: Properties
    let fetchedResultsController: FetchedResultsController1
    // swiftlint:disable:next identifier_name
    let fetchedResultsControllerHandler = FetchedResultsControllerHandler()
    
    private let changesPassthroughSubject = ChangesPassthroughSubjectType()
    
    private var changeBlocks: [(FetchedObjectsChangeType<T>) -> Void] = []
    
    public lazy var changesPublisher: AnyPublisher<FetchedObjectsChangeType<T>, Never> = {
        changesPassthroughSubject.eraseToAnyPublisher()
    }()
    
    internal init(
        fetchedResultsController: FetchedResultsController1.Type = FetchedResultsController1.self,
        context: NSManagedObjectContext,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        sectionNameKeyPath: String?
    ) {
        guard !sortDescriptors.isEmpty else {
            Logger.log.fatal("SortDescriptors mustn't be empty!")
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: T.entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        self.fetchedResultsController = fetchedResultsController.init(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        self.fetchedResultsController.delegate = fetchedResultsControllerHandler
        
        fetchedResultsControllerHandler.changeClosure = { [weak self] in
            self?.controller(didChange: $0, at: $1, for: $2, newIndexPath: $3)
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension FetchedObjectsController {
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
        fetchedResultsController.sections?.count ?? 0
    }
    
    // MARK: init
    public convenience init<V>(viewContext: SwiftDatastoreViewContext,
                               where: Where<T>? = nil,
                               orderBy: [OrderBy<T>],
                               groupBy: KeyPath<T, V>) where V: EntityPropertyKeyPath {
        self.init(context: viewContext.context,
                  predicate: `where`?.predicate,
                  sortDescriptors: orderBy.map { $0.sortDescriptor },
                  sectionNameKeyPath: groupBy.keyPathString)
    }
    
    public convenience init(viewContext: SwiftDatastoreViewContext,
                            where: Where<T>? = nil,
                            orderBy: [OrderBy<T>]) {
        self.init(context: viewContext.context,
                  predicate: `where`?.predicate,
                  sortDescriptors: orderBy.map { $0.sortDescriptor },
                  sectionNameKeyPath: nil)
    }
    
    // MARK: PerformFetch
    public func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.log.error("Performing fetch failed with error: \(error.localizedDescription)!")
        }
    }
    
    // MARK: SectionName
    public func sectionName(inSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    // MARK: NumberOfObjectsInSection
    public func numberOfObjects(inSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // MARK: GetObjectAtIndexPath
    public func getObject(at indexPath: IndexPath) -> T {
        let managedObject = fetchedResultsController.object(at: indexPath)
        return T(managedObject: managedObject)
    }
    
    // MARK: ObserveChanges
    public func observeChanges(_ block: @escaping (FetchedObjectsChangeType<T>) -> Void) {
        changeBlocks.append(block)
    }
}
