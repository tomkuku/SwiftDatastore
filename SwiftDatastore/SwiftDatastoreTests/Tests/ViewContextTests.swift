//
//  ViewContextTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 06/08/2022.
//

import XCTest

@testable import SwiftDatastore

class ViewContextTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = SwiftDatastoreViewContext
    
    var mock: ManagedObjectContextMock!
    var sut: SutType!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        mock = ManagedObjectContextMock()
        sut = SutType(context: mock)
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    // MARK: Fetch
    func test_fetch_fromEmptyStore_withNoParameters() throws {
        // when
        let fetchedObjects: [TestObject] = try sut.fetch(where: nil, orderBy: [], offset: 0, limit: 0)
        
        // then
        XCTAssertTrue(fetchedObjects.isEmpty)
        XCTAssertEqual(mock._fetchLimit, 0)
        XCTAssertEqual(mock._fetchOffset, 0)
        XCTAssertNil(mock._predicate)
        XCTAssertEqual(mock._sorts?.count, 0)
    }
    
    func test_fetch_fromNotEmptyStore() throws {
        // given
        let managedObject1 = createNewManagedObject()
        let managedObject2 = createNewManagedObject()
        let managedObject3 = createNewManagedObject()
        
        mock._fetchRequestResult = [managedObject1, managedObject2, managedObject3]
        
        // when
        let fetchedObjects: [TestObject] = try sut.fetch(where: nil, orderBy: [], offset: 0, limit: 0)
        
        // then
        XCTAssertEqual(fetchedObjects.count, 3)
        XCTAssertTrue(mock.executeFetchRequestCalled)
    }
    
    func test_fetch_fromEmptyStore_withParameters() throws {
        // given
        let expectedSortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                                       NSSortDescriptor(key: "dateBirth", ascending: false)]
        
        // when
        let fetchedObjects: [TestObject] = try sut.fetch(where: \.$age > 30,
                                                         orderBy: [.asc(\.$name), .desc(\.$dateBirth)],
                                                         offset: 999,
                                                         limit: 999)
        
        // then
        XCTAssertTrue(fetchedObjects.isEmpty)
        XCTAssertEqual(mock._fetchLimit, 999)
        XCTAssertEqual(mock._fetchOffset, 999)
        XCTAssertEqual(mock._predicate, NSPredicate(format: "age > 30"))
        XCTAssertEqual(mock._sorts?.count, 2)
        XCTAssertEqual(mock._sorts, expectedSortDescriptors)
    }
    
    // MARK: FetchFirst
    func test_fetchFirst() throws {
        // given
        let managedObject = createNewManagedObject()
        
        mock._fetchRequestResult = [managedObject]
        
        let expectedPredicate = "(age > 17 AND name == \"John\") OR height > 180"
        
        // when
        let fetchedObject: TestObject? = try sut.fetchFirst(where: \.$age > 17 && (\.$name == "John") || \.$height > 180,
                                                            orderBy: [.desc(\.$salary)])
        
        // then
        XCTAssertNotNil(fetchedObject)
        XCTAssertEqual(mock._fetchLimit, 1)
        XCTAssertEqual(mock._fetchOffset, 0)
        XCTAssertEqual(mock._predicate?.predicateFormat, expectedPredicate)
        XCTAssertEqual(mock._sorts?.count, 1)
        XCTAssertEqual(mock._sorts?.first, NSSortDescriptor(key: "salary", ascending: false))
    }
    
    // MARK: Count
    func test_count_fromEmptyStore() throws {
        // when
        let numberOfObjects = try sut.count(TestObject.self, where: \.$name |= "e")
        
        // then
        XCTAssertTrue(mock.countObjectsCalled)
        XCTAssertEqual(numberOfObjects, 0)
        XCTAssertEqual(mock._predicate?.predicateFormat, "name ENDSWITH \"e\"")
    }
    
    func test_count_fromNotEmptyStore() throws {
        // given
        let numberOfObjectsToCount = 4
        mock._numberOfObjectsToCount = numberOfObjectsToCount
        
        // when
        let numberOfObjects = try sut.count(TestObject.self, where: (\.$name ?= "Tom"))
        
        // then
        XCTAssertTrue(mock.countObjectsCalled)
        XCTAssertEqual(numberOfObjects, numberOfObjectsToCount)
        XCTAssertEqual(mock._predicate?.predicateFormat, "name CONTAINS \"Tom\"")
    }
}
