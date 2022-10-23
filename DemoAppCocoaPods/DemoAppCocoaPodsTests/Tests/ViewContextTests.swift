//
//  ViewContextTests.swift
//  DemoAppTests
//
//  Created by Kukułka Tomasz on 23/07/2022.
//
import XCTest
import Hamcrest
import CoreData
import SwiftDatastore
import UIKit

@testable import DemoAppCocoaPods

class ViewContextTests: XCTestCase {
    
    // MARK: Properties
    var sut: SwiftDatastoreViewContext!
    var datastoreContext: SwiftDatastoreContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let datastore = try SwiftDatastore(storingType: .test,
                                           storeName: "demoapp.view.context.tests",
                                           datamodelName: "DemoApp")
        
        sut = datastore.sharedViewContext
        datastoreContext = datastore.createNewContext()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: Fetch
    func test_fetch() throws {
        // given
        let expectation = XCTestExpectation()
        
        datastoreContext.perform { context in
            let employee1: Employee = try context.createObject()
            employee1.id = UUID()
            employee1.isInvalid = true
            employee1.salary = 1620.00
            
            let employee3: Employee = try context.createObject()
            employee3.id = UUID()
            employee3.isInvalid = true
            employee3.salary = 4450.00
            
            let employee4: Employee = try context.createObject()
            employee4.id = UUID()
            employee4.isInvalid = false
            employee4.salary = 1000.00
            
            try context.saveChanges()
        } success: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        // when
        let fetchedEmployee: [Employee] = try sut.fetch(where: \.$isInvalid == true && \.$salary < 5000,
                                                        orderBy: [.asc(\.$salary)])
        
        // then
        assertThat(fetchedEmployee.first?.isInvalid, equalTo(true))
        assertThat(fetchedEmployee.first?.salary, equalTo(1620.00))
        assertThat(fetchedEmployee.count, equalTo(2))
    }
    
    // MARK: FetchFirst
    func test_fetchFirst() throws {
        // given
        let expectation = XCTestExpectation()
        
        datastoreContext.perform { context in
            let employee1: Employee = try context.createObject()
            employee1.id = UUID()
            employee1.isInvalid = true
            employee1.salary = 1000
            
            let employee3: Employee = try context.createObject()
            employee3.id = UUID()
            employee3.isInvalid = true
            employee3.salary = 2000
            
            let employee4: Employee = try context.createObject()
            employee4.id = UUID()
            employee4.isInvalid = false
            employee4.salary = 3000
            
            try context.saveChanges()
        } success: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        // when
        let fetchedEmployee: Employee? = try sut.fetchFirst(orderBy: [.desc(\.$salary)])
        
        // then
        assertThat(fetchedEmployee?.salary, equalTo(3000))
    }
    
    // MARK: Count
    func test_count() throws {
        // given
        let expectation = XCTestExpectation()
        
        datastoreContext.perform { context in
            let employee1: Employee = try context.createObject()
            employee1.salary = 1620.00
            
            let employee3: Employee = try context.createObject()
            employee3.salary = 4450.00
            
            let employee4: Employee = try context.createObject()
            employee4.salary = 1000.00
            
            try context.saveChanges()
        } success: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        // when
        let numberOfEmployees = try sut.count(Employee.self, where: \.$salary > 1000)
        
        // then
        assertThat(numberOfEmployees, equalTo(2))
    }
}
