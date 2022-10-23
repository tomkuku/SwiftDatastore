//
//  ObserveEntityAttributeTests.swift
//  DemoAppCocoaPodsTests
//
//  Created by Kukułka Tomasz on 02/10/2022.
//

import XCTest
import Combine

import SwiftDatastore
import Hamcrest

@testable import DemoAppCocoaPods

class ObserveEntityAttributeTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = SwiftDatastoreContext
    
    var sut: SutType!
    var viewContext: SwiftDatastoreViewContext!
    var expectation: XCTestExpectation!
    var cancellable: Set<AnyCancellable> = []
    
    // MARK: Setup
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let datastore = try SwiftDatastore(storingType: .test,
                                           storeName: "demoapp.background.context.tests",
                                           datamodelName: "DemoApp")
        
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
    
    // MARK: OptionalAttribute
    func test_observe_optionalAttribute() {
        // given
        var employee: Employee!
        let observerExpectation = XCTestExpectation(fulfillmentCount: 2)
        var newSalary: Float? = 0.0
        
        sut.perform { context in
            employee = try context.createObject()
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        employee.$salary.observe { newValue in
            newSalary = newValue
            observerExpectation.fulfill()
        }
        
        employee.$salary
            .newValuePublisher
            .sink { _ in
                observerExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.perform { context in
            employee.salary = nil
        }
        
        // then
        wait(for: [observerExpectation], timeout: 2)
        assertThat(newSalary, equalTo(nil))
    }
    
    // MARK: NotOptionalAttribute
    func test_observe_notOptionalAttribute() {
        // given
        var employee: Employee!
        let observerExpectation = XCTestExpectation(fulfillmentCount: 2)
        let expectedID = UUID()
        var newId: UUID!
        
        sut.perform { context in
            employee = try context.createObject()
            employee.id = UUID()
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        employee.$id.observe { newValue in
            newId = newValue
            observerExpectation.fulfill()
        }
        
        employee.$id
            .newValuePublisher
            .sink { _ in
                observerExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.perform { context in
            employee.id = expectedID
        }
        
        // then
        wait(for: [observerExpectation], timeout: 2)
        assertThat(newId, equalTo(expectedID))
    }
    
    // MARK: EnumAttribute
    func test_observe_enumAttribute() {
        // given
        var employee: Employee!
        let observerExpectation = XCTestExpectation(fulfillmentCount: 2)
        let expectedPosition = Position.developer
        var newPosition: Position!
        
        sut.perform { context in
            employee = try context.createObject()
            employee.position = .productOwner
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        employee.$position.observe { newValue in
            newPosition = newValue
            observerExpectation.fulfill()
        }
        
        employee.$position
            .newValuePublisher
            .sink { _ in
                observerExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.perform { context in
            employee.position = expectedPosition
        }
        
        // then
        wait(for: [observerExpectation], timeout: 2)
        assertThat(newPosition, equalTo(expectedPosition))
    }
    
    // MARK: ToOneRelationship
    func test_observe_toOneRelationship() {
        // given
        var employee: Employee!
        var company: Company!
        let observerExpectation = XCTestExpectation(fulfillmentCount: 2)
        var newCompany: Company!
        
        sut.perform { context in
            company = try context.createObject()
            company.name = "Abc inc."
            employee = try context.createObject()
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        employee.$company.observe { newValue in
            newCompany = newValue
            observerExpectation.fulfill()
        }
        
        employee.$company
            .newValuePublisher
            .sink { _ in
                observerExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.perform { context in
            employee.company = company
        }
        
        // then
        wait(for: [observerExpectation], timeout: 2)
        assertThat(newCompany.datastoreObjectID, equalTo(company.datastoreObjectID))
    }
    
    // MARK: ToManyRelationship
    func test_observe_toManyRelationship_setObjects() {
        // given
        var company: Company!
        var employees: Set<Employee> = []
        var newEmployees: Set<Employee> = []
        let observerExpectation = XCTestExpectation(fulfillmentCount: 2)
        
        sut.perform { context in
            employees = try Set<Employee>(repating: 3) {
                try context.createObject()
            }
            
            company = try context.createObject()
            company.name = "Abc inc."
            try context.saveChanges()
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        company.$employees.observe { newValue in
            observerExpectation.fulfill()
        }
        
        company.$employees
            .newValuePublisher
            .sink { newValue in
                newEmployees = newValue
                observerExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.perform { context in
            company.employees = employees
        }
        
        // then
        wait(for: [observerExpectation], timeout: 4)
        assertThat(newEmployees.count, equalTo(employees.count))
        assertThat(company.employees.count, equalTo(employees.count))
    }
    
    func test_observe_toManyRelationship_removeObjects() {
        // given
        var company: Company!
        var newEmployees: Set<Employee> = []
        let observerExpectation = XCTestExpectation(fulfillmentCount: 4)
        
        sut.perform { context in
            let employees = try Set<Employee>(repating: 3) {
                try context.createObject()
            }
            
            company = try context.createObject()
            company.name = "Abc inc."
            company.employees = employees
            try context.saveChanges()
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        company.$employees.observe { newValue in
            observerExpectation.fulfill()
        }
        
        company.$employees
            .newValuePublisher
            .sink { newValue in
                newEmployees = newValue
                observerExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.perform { context in
            company.employees.removeFirst()
            company.employees.removeFirst()
        }
        
        // then
        wait(for: [observerExpectation], timeout: 4)
        assertThat(newEmployees.count, equalTo(1))
        assertThat(company.employees.count, equalTo(1))
    }
    
    func test_observe_toManyRelationship_removeAllObjects() {
        // given
        var company: Company!
        var newEmployees: Set<Employee> = []
        let observerExpectation = XCTestExpectation()
        
        sut.perform { context in
            let employees = try Set<Employee>(repating: 3) {
                try context.createObject()
            }
            
            company = try context.createObject()
            company.name = "Abc inc."
            company.employees = employees
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        company.$employees.observe { newValue in
            observerExpectation.fulfill()
        }
        
        company.$employees
            .newValuePublisher
            .sink { newValue in
                newEmployees = newValue
                observerExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.perform { context in
            company.employees.removeAll()
        }
        
        // then
        wait(for: [observerExpectation], timeout: 4)
        assertThat(newEmployees, empty())
        assertThat(company.employees, empty())
    }
    
    func test_observe_toManyRelationship_insertObjects() {
        // given
        var company: Company!
        var newEmployees: Set<Employee> = []
        let observerExpectation = XCTestExpectation(fulfillmentCount: 4)
        
        sut.perform { context in
            let employees = try Set<Employee>(repating: 3) {
                try context.createObject()
            }
            
            company = try context.createObject()
            company.name = "Abc inc."
            company.employees = employees
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        company.$employees.observe { newValue in
            observerExpectation.fulfill()
        }
        
        company.$employees
            .newValuePublisher
            .sink { newValue in
                newEmployees = newValue
                observerExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        // when
        sut.perform { context in
            let employee1: Employee = try context.createObject()
            let employee2: Employee = try context.createObject()
            company.employees.insert(employee1)
            company.employees.insert(employee2)
        }
        
        // then
        wait(for: [observerExpectation], timeout: 4)
        assertThat(newEmployees.count, equalTo(5))
        assertThat(company.employees.count, equalTo(5))        
    }
}
