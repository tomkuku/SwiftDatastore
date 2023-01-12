//
//  FetchedObjectsControllerTests.swift
//  DemoAppTests
//
//  Created by Kukułka Tomasz on 10/08/2022.
//

import XCTest
import SwiftDatastore

@testable import TestApp

class FetchedObjectsControllerTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = FetchedObjectsController<Employee>
    
    var sut: SutType!
    var viewContext: SwiftDatastoreViewContext!
    var datastoreContext: SwiftDatastoreContext!
    
    // MARK: Setup
    override func setUpWithError() throws {
        super.setUp()
        
        let model = SwiftDatastoreModel(from: Employee.self, Company.self, Car.self)
        let datastore = try SwiftDatastore(datastoreModel: model,
                                           storeName: "demoapp.fetched.objects.controller.tests",
                                           storingType: .test)
        
        viewContext = datastore.sharedViewContext
        datastoreContext = datastore.createNewContext()
        
        sut = SutType(viewContext: viewContext,
                      orderBy: [.asc(\.$salary)],
                      groupBy: \.$position)
    }
    
    override func tearDown() {
        sut = nil
        viewContext = nil
        super.tearDown()
    }
    
    // MARK: NumberOfSections
    func test_numberOfSections() {
        // given
        let saveExpectation = XCTestExpectation()
        
        datastoreContext.perform { context in
            let developer1: Employee = try context.createObject()
            developer1.position = .developer
            
            let developer2: Employee = try context.createObject()
            developer2.position = .developer
            
            let productOwner1: Employee = try context.createObject()
            productOwner1.position = .productOwner
            
            let productOwner2: Employee = try context.createObject()
            productOwner2.position = .productOwner
            
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 2)
        
        sut.performFetch()
                
        // when
        let numberOfSections = sut.numberOfSections
        
        // then
        XCTAssertEqual(numberOfSections, 2)
    }
    
    // MARK: NumberOfObjectsInSection
    func test_numberOfObjectsInSection() {
        // given
        let expectation = XCTestExpectation()
        
        datastoreContext.perform { context in
            let developer1: Employee = try context.createObject()
            developer1.position = .developer
            
            let developer2: Employee = try context.createObject()
            developer2.position = .developer
            
            try context.saveChanges()
        } success: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        sut.performFetch()
        
        // when
        let numberOfObjectsSection = sut.numberOfObjects(inSection: 0)
        
        // then
        XCTAssertEqual(numberOfObjectsSection, 2)
    }
    
    // MARK: GetObjectAtIndexPath
    func test_getObjectAtIndexPath() {
        // given
        let expectation = XCTestExpectation()
        
        datastoreContext.perform { context in
            let developer1: Employee = try context.createObject()
            developer1.position = .developer
            developer1.salary = 3000
            
            let developer2: Employee = try context.createObject()
            developer2.position = .developer
            developer2.salary = 2000
            
            let productOwner1: Employee = try context.createObject()
            productOwner1.position = .productOwner
            productOwner1.salary = 4000
            
            try context.saveChanges()
        } success: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        sut.performFetch()
        
        let indexPath = IndexPath(row: 1, section: 0)
        
        // when
        let objectAtIndexPath = sut.getObject(at: indexPath)
        
        // then
        XCTAssertEqual(objectAtIndexPath.salary, 3000)
    }
    
    // MARK: SectionNameInSection
    func test_sectionNameInSection() {
        // given
        let expectation = XCTestExpectation()
        
        datastoreContext.perform { context in
            let developer1: Employee = try context.createObject()
            developer1.position = .developer
            
            let developer2: Employee = try context.createObject()
            developer2.position = .developer
            
            try context.saveChanges()
        } success: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        sut.performFetch()
        
        // when
        let numberOfObjectsSection = sut.sectionName(inSection: 0)
        
        // then
        XCTAssertEqual(numberOfObjectsSection, "0")
    }
    
    // MARK: ObserveChanges Inserted
    func test_observeChanges_inserted() {
        // given
        let saveExpectation = XCTestExpectation()
        
        sut.performFetch()

        datastoreContext.perform { context in
            let developer1: Employee = try context.createObject()
            developer1.position = .developer
            developer1.salary = 1000
            
            let developer2: Employee = try context.createObject()
            developer2.position = .developer
            developer2.salary = 2000
            
            try context.saveChanges()
        } success: {
                saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 2)
        
        let observeChangesExpectation = XCTestExpectation()
        var insertedEmployeeIndexPath: IndexPath?
        var insertedEmployee: Employee?
        
        sut.observeChanges { change in
            if case let .inserted(object, indexPath) = change {
                insertedEmployee = object
                insertedEmployeeIndexPath = indexPath
                observeChangesExpectation.fulfill()
            } else {
                XCTFail("No other change expected")
            }
        }
        
        // when
        datastoreContext.perform { context in
            let newEmployee: Employee = try context.createObject()
            newEmployee.position = .developer
            newEmployee.salary = 3000
            
            try context.saveChanges()
        }
        
        // then
        wait(for: [observeChangesExpectation], timeout: 3)
        XCTAssertEqual(insertedEmployee?.salary, 3000)
        XCTAssertEqual(insertedEmployeeIndexPath, IndexPath(row: 2, section: 0))
    }
    
    // MARK: ObserveChanges Deleted
    func test_observeChanges_deleted() {
        // given
        let saveExpectation = XCTestExpectation()
        var developer1: Employee!
        
        sut.performFetch()

        datastoreContext.perform { context in
            developer1 = try context.createObject()
            developer1.position = .developer
            developer1.salary = 2000
            
            let developer2: Employee = try context.createObject()
            developer2.position = .developer
            developer2.salary = 1000
            
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 2)
        
        let observeChangesExpectation = XCTestExpectation()
        var deletedEmployeeIndexPath: IndexPath?
        
        sut.observeChanges { change in
            if case let .deleted(indexPath) = change {
                deletedEmployeeIndexPath = indexPath
                observeChangesExpectation.fulfill()
            } else {
                XCTFail("No other change expected")
            }
        }
        
        // when
        datastoreContext.perform { context in
            context.deleteObject(developer1)
            
            try context.saveChanges()
        }
        
        // then
        wait(for: [observeChangesExpectation], timeout: 3)
        XCTAssertEqual(deletedEmployeeIndexPath, IndexPath(row: 1, section: 0))
    }
    
    // MARK: ObserveChanges Updated
    func test_observeChanges_updated() {
        // given
        let saveExpectation = XCTestExpectation()
        var developer1: Employee!
        
        sut.performFetch()
        
        datastoreContext.perform { context in
            developer1 = try context.createObject()
            developer1.position = .developer
            developer1.salary = 2000
            
            let developer2: Employee = try context.createObject()
            developer2.position = .developer
            developer2.salary = 1000
            
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 2)
                
        let observeChangesExpectation = XCTestExpectation()
        var updatedEmployeeIndexPath: IndexPath?
        var updatedEmployee: Employee?
        
        sut.observeChanges { change in
            if case let .updated(object, indexPath) = change {
                updatedEmployee = object
                updatedEmployeeIndexPath = indexPath
                observeChangesExpectation.fulfill()
            } else {
                XCTFail("No other change expected")
            }
        }
        
        // when
        datastoreContext.perform { context in
            developer1.isInvalid = true
            
            try context.saveChanges()
        }
        
        // then
        wait(for: [observeChangesExpectation], timeout: 3)
        XCTAssertEqual(updatedEmployee?.salary, 2000)
        XCTAssertEqual(updatedEmployeeIndexPath, IndexPath(row: 1, section: 0))
    }
    
    // MARK: ObserveChanges Moved
    func test_observeChanges_moved() {
        // given
        let saveExpectation = XCTestExpectation()
        var employee1: Employee!
        
        sut.performFetch()
        
        datastoreContext.perform { context in
            employee1 = try context.createObject()
            employee1.position = .developer
            employee1.salary = 1000
            
            let employee2: Employee = try context.createObject()
            employee2.position = .developer
            employee2.salary = 2000
            
            let employee3: Employee = try context.createObject()
            employee3.position = .developer
            employee3.salary = 3000
            
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 2)
                
        let observeChangesExpectation = XCTestExpectation()
        var fromIndexPath: IndexPath?
        var toIndexPath: IndexPath?
        var movedEmployee: Employee?
        
        sut.observeChanges { change in
            if case let .moved(object, sourceIndexPath, destinationIndexPath) = change {
                movedEmployee = object
                fromIndexPath = sourceIndexPath
                toIndexPath = destinationIndexPath
                observeChangesExpectation.fulfill()
            } else {
                XCTFail("No other change expected")
            }
        }
        
        // when
        datastoreContext.perform { context in
            employee1.salary = 50000
            
            try context.saveChanges()
        }
        
        // then
        wait(for: [observeChangesExpectation], timeout: 3)
        XCTAssertEqual(movedEmployee?.salary, 50000)
        XCTAssertEqual(fromIndexPath, IndexPath(row: 0, section: 0))
        XCTAssertEqual(toIndexPath, IndexPath(row: 2, section: 0))
    }
}

