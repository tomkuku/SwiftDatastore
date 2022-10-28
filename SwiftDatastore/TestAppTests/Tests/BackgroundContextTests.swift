//
//  BackgroundContextTests.swift
//  DemoAppTests
//
//  Created by Kukułka Tomasz on 04/08/2022.
//

import XCTest
import SwiftDatastore

@testable import TestApp

class BackgroundContextTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = SwiftDatastoreContext
    
    var sut: SutType!
    var viewContext: SwiftDatastoreViewContext!
    var expectation: XCTestExpectation!
    var datastore: SwiftDatastore!
    
    // MARK: Setup
    override func setUpWithError() throws {
        super.setUp()
        
        datastore = try SwiftDatastore(storingType: .test,
                                       storeName: "demoapp.background.context.tests",
                                       datamodelName: "TestApp")
        
        viewContext = datastore.sharedViewContext
        sut = datastore.createNewContext()
        
        expectation = XCTestExpectation()
    }
    
    override func tearDown() {
        sut = nil
        viewContext = nil
        expectation = nil
        super.tearDown()
    }
    
    // MARK: Crate Object
    func test_createObject() {
        // when
        sut.perform { context in
            let _: Employee = try context.createObject()
        } success: {
            self.expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        
        // then
        wait(for: [expectation], timeout: 2)
    }
    
    // MARK: FetchProperties
    func test_fetchProperties() throws {
        // given
        let saveExpectation = XCTestExpectation()
        let fetchExpectation = XCTestExpectation()
        var fetchedProperties: [[String: Any?]] = []
        
        sut.perform { context in
            let employee1: Employee = try context.createObject()
            employee1.name = "John"
            employee1.salary = 1620.00
            
            let employee2: Employee = try context.createObject()
            employee2.name = "Tom"
            employee2.salary = 4450.00
            
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 2)
        
        // when
        sut.perform { context in
            fetchedProperties = try context.fetch(Employee.self,
                                                  properties: [.init(\.$name), .init(\.$salary), .init(\.$id)],
                                                  orderBy: [.asc(\.$salary)])
        } success: {
            fetchExpectation.fulfill()
        }
        
        // then
        wait(for: [fetchExpectation], timeout: 2)
        XCTAssertEqual(fetchedProperties.count, 2)
        XCTAssertEqual(fetchedProperties.first?.count, 3)
        XCTAssertEqual(fetchedProperties.first?["name"] as? String, "John")
    }
    
    // MARK: Revert Changes
    func test_revertChanges() throws {
        // given
        let saveExpectation = XCTestExpectation()
        
        sut.perform { context in
            let employee: Employee = try context.createObject()
            employee.id = UUID()
            employee.salary = 3000.00
            
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 2)
        
        // when
        sut.perform { context in
            let employee: Employee = try context.fetchFirst(orderBy: [.asc(\.$salary)])!
            employee.salary = 4000.00
            
            context.revertChanges()
        } success: {
            self.expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 2)
        
        let employee: Employee = try viewContext.fetchFirst(orderBy: [.asc(\.$salary)])!
        
        XCTAssertEqual(employee.salary, 3000)
    }
    
    // MARK: Delete Object
    func test_deleteObject() throws {
        // when
        sut.perform { context in
            let employee: Employee = try context.createObject()
            
            try context.saveChanges()
            
            let company: Company = try context.createObject()
            
            context.deleteObject(employee)
            context.deleteObject(company)
            
            try context.saveChanges()
        } success: {
            self.expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        
        // then
        wait(for: [expectation], timeout: 2)
        
        let employees: [Employee] = try viewContext.fetch()
        let companies: [Company] = try viewContext.fetch()
        
        XCTAssertTrue(employees.isEmpty)
        XCTAssertTrue(companies.isEmpty)
    }
    
    // MARK: Delete Many
    func test_deleteMany() throws {
        // given
        let triggerSalary: Float = 3000
        var numberOfDeletedObjects = Int.max
        let saveExpectation = XCTestExpectation()
        
        sut.perform { context in
            let salaries: [Float] = [2000.00, 2500.00, 3000.00, 3700.00]
            var employees: [Employee] = []
            
            for salary in salaries {
                let employee: Employee = try context.createObject()
                employee.id = UUID()
                employee.salary = salary
                employees.append(employee)
            }
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 3)
        
        // when
        sut.perform { context in
            numberOfDeletedObjects = try context.deleteMany(Employee.self, where: \.$salary < triggerSalary)
        } success: {
            self.expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        
        // then
        wait(for: [expectation], timeout: 2)
        
        let employees: [Employee] = try viewContext.fetch()
        
        XCTAssertEqual(employees.count, 2)
        XCTAssertEqual(numberOfDeletedObjects, 2)
        
        employees.forEach {
            XCTAssertGreaterThanOrEqual($0.salary!, triggerSalary)
        }
    }
    
    // MARK: Update Many
    func test_updateMany() throws {
        // given
        let triggerSalary: Float = 3000
        var numberOfUpdatedObjects = Int.max
        let saveExpectation = XCTestExpectation()
        
        sut.perform { context in
            let salaries: [Float] = [2000.00, 2500.00, 3000.00, 3700.00]
            var employees: [Employee] = []
            
            for salary in salaries {
                let employee: Employee = try context.createObject()
                employee.id = UUID()
                employee.salary = salary
                employees.append(employee)
            }
            
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 3)
        
        // when
        sut.perform { context in
            numberOfUpdatedObjects = try context.updateMany(Employee.self,
                                                            where: \.$salary < triggerSalary,
                                                            propertiesToUpdate: [.init(\.$salary, 4000)])
        } success: {
            self.expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        
        // then
        wait(for: [expectation], timeout: 2)
        
        let employees: [Employee] = try viewContext.fetch()
        
        XCTAssertEqual(employees.count, 4)
        XCTAssertEqual(numberOfUpdatedObjects, 2)
        
        employees.forEach {
            XCTAssertGreaterThanOrEqual($0.salary!, triggerSalary)
        }
    }
    
    // MARK: Convert Existing Object
    func test_convertExistingObject() throws {
        // given
        let parentContext1 = datastore.createNewContext()
        let parentContext2 = datastore.createNewContext()
        
        let childContext1 = parentContext1.createNewChildContext()
        let childContext2 = parentContext2.createNewChildContext()
        
        let saveExpectation = XCTestExpectation()
        
        var employee1: Employee!
        var convertedEmplyeeSalary: Float?
        
        childContext1.perform { context in
            employee1 = try context.createObject()
            employee1.salary = 4000
            try context.saveChanges()
        } success: {
            parentContext1.perform { context in
                try context.saveChanges()
            } success: {
                saveExpectation.fulfill()
            }
        }
        
        wait(for: [saveExpectation], timeout: 2)
                
        // when
        childContext2.perform { context in
            let employee = try context.convert(existingObject: employee1)
            convertedEmplyeeSalary = employee.salary
        } success: {
            self.expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(convertedEmplyeeSalary, 4000)
    }
    
    // MARK: Refresh
    func test_refresh() {
        // given
        let parentContext1 = datastore.createNewContext()
        let parentContext2 = datastore.createNewContext()
        
        let childContext1 = parentContext1.createNewChildContext()
        let childContext2 = parentContext2.createNewChildContext()
        
        var changedEmployee1: Employee!
        var changedEmployee2: Employee?
        
        var deletedEmployee1: Employee!
        var deletedEmployee2: Employee?
        
        let saveExpectation = XCTestExpectation()
        let fetchExpectation = XCTestExpectation()
        let changeExpectation = XCTestExpectation()
        let mergeExpectation = XCTestExpectation()
        
        var changes: SwiftDatastoreSavedChanges!
        
        childContext1.perform { context in
            changedEmployee1 = try context.createObject()
            changedEmployee1.salary = 1111
            deletedEmployee1 = try context.createObject()
            deletedEmployee1.salary = 7777
            try context.saveChanges()
        } success: {
            parentContext1.perform { context in
                try context.saveChanges()
            } success: {
                saveExpectation.fulfill()
            }
        }
        
        wait(for: [saveExpectation], timeout: 2)
        
        childContext2.perform { context in
            changedEmployee2 = try context.fetchFirst(orderBy: [.asc(\.$salary)])!
            changedEmployee2?.salary = 4444
            deletedEmployee2 = try context.convert(existingObject: deletedEmployee1)
            deletedEmployee2?.salary = 2222
        } success: {
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 2)
        
        childContext1.perform { context in
            changedEmployee1.salary = 8888
            context.deleteObject(deletedEmployee1)
            let employee: Employee = try context.createObject()
            employee.salary = 9999
            
            changes = try context.saveChanges()
        } success: {
            parentContext1.perform { context in
                try context.saveChanges()
            } success: {
                changeExpectation.fulfill()
            }
        }
        
        wait(for: [changeExpectation], timeout: 2)
        
        childContext2.perform { context in
            context.refresh(using: changes)
        } success: {
            mergeExpectation.fulfill()
        }

        wait(for: [mergeExpectation], timeout: 2)
        
        XCTAssertEqual(changedEmployee2?.salary, 8888)
        XCTAssertNil(deletedEmployee2?.salary)
    }
}
