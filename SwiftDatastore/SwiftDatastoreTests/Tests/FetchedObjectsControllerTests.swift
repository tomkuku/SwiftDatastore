//
//  FetchedObjectsControllerTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 08/08/2022.
//

import Foundation
import CoreData
import XCTest
import Combine

@testable import SwiftDatastore

class FetchedObjectsControllerTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = FetchedObjectsController<TestObject>
    
    var sut: SutType!
    var managedObjectContextMock: ManagedObjectContextMock!
    var fetchedResultsControllerMock: FetchedResultsControllerMock!
    var cancellable: Set<AnyCancellable> = []
    
    let frcDummy = NSFetchedResultsController<NSFetchRequestResult>()
    
    override func setUp() {
        super.setUp()
        managedObjectContextMock = PersistentStoreCoordinatorMock.shared.mocMock
        
        fetchedResultsControllerMock = FetchedResultsControllerMock()
        
        sut = SutType(fetchedResultsController: FetchedResultsControllerMock.self,
                      context: managedObjectContextMock,
                      predicate: nil,
                      sortDescriptors: [NSSortDescriptor(key: "age", ascending: false)],
                      sectionNameKeyPath: "salary")
        
        fetchedResultsControllerMock = sut.fetchedResultsController as? FetchedResultsControllerMock
    }
    
    override func tearDown() {
        sut = nil
        managedObjectContextMock = nil
        fetchedResultsControllerMock = nil
        super.tearDown()
    }
    
    // MARK: PerformFetch
    func test_performFetch() {
        // when
        let _ = sut.performFetch()
        
        // then
        XCTAssertTrue(fetchedResultsControllerMock.performFetchCalled)
    }
    
    // MARK: Init
    func test_initWithGroupBy() {
        // given
        let viewContext = SwiftDatastoreViewContext(context: managedObjectContextMock)
        
        // when
        sut = SutType(viewContext: viewContext,
                      where: \.$name == "abc",
                      orderBy: [.asc(\.$age)],
                      groupBy: .init(\.$salary))
        
        // then
        let fetchRequest = sut.fetchedResultsController.fetchRequest
        XCTAssertEqual(fetchRequest.predicate?.predicateFormat, "name == \"abc\"")
        XCTAssertEqual(fetchRequest.sortDescriptors, [NSSortDescriptor(key: "age", ascending: true)])
        XCTAssertEqual(sut.fetchedResultsController.sectionNameKeyPath, "salary")
    }
    
    func test_initWithoutGroupBy() {
        // given
        let viewContext = SwiftDatastoreViewContext(context: managedObjectContextMock)
        
        // when
        sut = SutType(viewContext: viewContext,
                      where: \.$name == "abc",
                      orderBy: [.asc(\.$age)])
        
        // then
        let fetchRequest = sut.fetchedResultsController.fetchRequest
        XCTAssertEqual(fetchRequest.predicate?.predicateFormat, "name == \"abc\"")
        XCTAssertEqual(fetchRequest.sortDescriptors, [NSSortDescriptor(key: "age", ascending: true)])
        XCTAssertNil(sut.fetchedResultsController.sectionNameKeyPath)
    }
    
    // MARK: NumberOfSections
    func test_numberOfSections() {
        // given
        let sections = [FetchedResultsSectionInfoMock(), FetchedResultsSectionInfoMock()]
        fetchedResultsControllerMock._sections = sections
        
        // when
        let numberOfSections = sut.numberOfSections
        
        // then
        XCTAssertEqual(numberOfSections, sections.count)
    }
    
    // MARK: NumberOfObjectsInSection
    func test_numberOfObjectsInSection() {
        // given
        let numberOfObjects = 23
        
        let sectionMock = FetchedResultsSectionInfoMock()
        sectionMock.numberOfObjects = numberOfObjects
        
        fetchedResultsControllerMock._sections = [sectionMock]
        
        // when
        let gotNumberOfObjects = sut.numberOfObjects(inSection: 0)
        
        // then
        XCTAssertEqual(gotNumberOfObjects, numberOfObjects)
    }
    
    // MARK: GetObjectAtIndexPath
    func test_getObjectAtIndexPath() {
        // given
        let indexPath = IndexPath(row: 1, section: 3)
        
        fetchedResultsControllerMock._indexPath = indexPath
        
        // when
        let _ = sut.getObject(at: indexPath)
        
        // then
        XCTAssertTrue(fetchedResultsControllerMock.objectAtIndexPathCalled)
        XCTAssertEqual(fetchedResultsControllerMock._indexPath, indexPath)
    }
    
    // MARK: SectionNameInSection
    func test_sectionNameInSection() {
        // given
        let sectionName = "abc"
        
        let sectionMock = FetchedResultsSectionInfoMock()
        sectionMock.name = sectionName
        
        fetchedResultsControllerMock._sections = [sectionMock]
        
        // when
        let gotSectionName = sut.sectionName(inSection: 0)
        
        // then
        XCTAssertEqual(gotSectionName, sectionName)
    }
    
    // MARK: ObserveChanges Inserted
    func test_observeChanges_inserted() {
        // given
        let newIndexPath = IndexPath(row: 2, section: 10)
        var insertedIndexPath: IndexPath?
        
        let expectation = XCTestExpectation(fulfillmentCount: 2)
        
        sut.observeChanges { change in
            if case let .inserted(_, indexPath) = change {
                insertedIndexPath = indexPath
                expectation.fulfill()
            } else {
                XCTFail("No other change expected")
            }
        }
        
        sut
            .changesPublisher
            .filter {
                if case .inserted = $0 {
                    return true
                }
                return false
            }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.fetchedResultsControllerHandler.controller(frcDummy,
                                                       didChange: createNewManagedObject(),
                                                       at: nil,
                                                       for: .insert,
                                                       newIndexPath: newIndexPath)
        
        // then
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(insertedIndexPath, newIndexPath)
    }
    
    // MARK: ObserveChanges Deleted
    func test_observeChanges_deleted() {
        // given
        let atIndexPath = IndexPath(row: 2, section: 10)
        var deletedIndexPath: IndexPath?
        
        let expectation = XCTestExpectation(fulfillmentCount: 2)
        
        sut.observeChanges { change in
            if case let .deleted(indexPath) = change {
                deletedIndexPath = indexPath
                expectation.fulfill()
            } else {
                XCTFail("No other change expected")
            }
        }
        
        sut
            .changesPublisher
            .filter {
                if case .deleted = $0 {
                    return true
                }
                return false
            }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.fetchedResultsControllerHandler.controller(frcDummy,
                                                       didChange: createNewManagedObject(),
                                                       at: atIndexPath,
                                                       for: .delete,
                                                       newIndexPath: nil)
        // then
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(deletedIndexPath, atIndexPath)
    }
    
    // MARK: ObserveChanges Updated
    func test_observeChanges_updated() {
        // given
        let atIndexPath = IndexPath(row: 2, section: 10)
        var updatedIndexPath: IndexPath?
        
        let expectation = XCTestExpectation(fulfillmentCount: 2)
        
        sut.observeChanges { change in
            if case let .updated(_, indexPath) = change {
                updatedIndexPath = indexPath
                expectation.fulfill()
            } else {
                XCTFail("No other change expected")
            }
        }
        
        sut
            .changesPublisher
            .filter {
                if case .updated = $0 {
                    return true
                }
                return false
            }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.fetchedResultsControllerHandler.controller(frcDummy,
                                                       didChange: createNewManagedObject(),
                                                       at: atIndexPath,
                                                       for: .update,
                                                       newIndexPath: nil)
        
        // then
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(updatedIndexPath, atIndexPath)
    }
    
    // MARK: ObserveChanges Moved
    func test_observeChanges_moved() {
        // given
        let atIndexPath = IndexPath(row: 2, section: 10)
        let newIndexPath = IndexPath(row: 3, section: 11)
        
        let expectation = XCTestExpectation(fulfillmentCount: 2)
        var fromIndexPath: IndexPath?
        var toIndexPath: IndexPath?
        
        sut.observeChanges { change in
            if case let .moved(_, sourceIndexPath, destinationIndexPath) = change {
                fromIndexPath = sourceIndexPath
                toIndexPath = destinationIndexPath
                expectation.fulfill()
            } else {
                XCTFail("No other change expected")
            }
        }
        
        sut
            .changesPublisher
            .filter {
                if case .moved = $0 {
                    return true
                }
                return false
            }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.fetchedResultsControllerHandler.controller(frcDummy,
                                                       didChange: createNewManagedObject(),
                                                       at: atIndexPath,
                                                       for: .move,
                                                       newIndexPath: newIndexPath)
        
        // then
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(fromIndexPath, atIndexPath)
        XCTAssertEqual(toIndexPath, newIndexPath)
        
    }
}

extension XCTestExpectation {
    convenience init(fulfillmentCount: Int) {
        self.init()
        self.expectedFulfillmentCount = fulfillmentCount
    }
}
