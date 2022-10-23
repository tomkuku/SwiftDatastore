//
//  ViewContextTests.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 06/08/2022.
//

import XCTest
import Hamcrest

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
        assertThat(fetchedObjects, empty())
        assertThat(mock._fetchLimit, equalTo(0))
        assertThat(mock._fetchOffset, equalTo(0))
        assertThat(mock._predicate, equalTo(nil))
        assertThat(mock._sorts?.count, equalTo(0))
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
        assertThat(fetchedObjects.count, equalTo(3))
        assertThat(mock.executeFetchRequestCalled ==  true)
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
        assertThat(fetchedObjects, empty())
        assertThat(mock._fetchLimit, equalTo(999))
        assertThat(mock._fetchOffset, equalTo(999))
        assertThat(mock._predicate, equalTo(NSPredicate(format: "age > 30")))
        assertThat(mock._sorts?.count, equalTo(2))
        assertThat(mock._sorts, equalTo(expectedSortDescriptors))
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
        assertThat(fetchedObject, not(nil))
        assertThat(mock._fetchLimit, equalTo(1))
        assertThat(mock._fetchOffset, equalTo(0))
        assertThat(mock._predicate?.predicateFormat, equalTo(expectedPredicate))
        assertThat(mock._sorts?.count, equalTo(1))
        assertThat(mock._sorts?.first, equalTo(NSSortDescriptor(key: "salary", ascending: false)))
    }
    
    // MARK: Count
    func test_count_fromEmptyStore() throws {
        // when
        let numberOfObjects = try sut.count(TestObject.self, where: \.$name |= "e")
        
        // then
        assertThat(mock.countObjectsCalled == true)
        assertThat(numberOfObjects, equalTo(0))
        assertThat(mock._predicate?.predicateFormat, equalTo("name ENDSWITH \"e\""))
    }
    
    func test_count_fromNotEmptyStore() throws {
        // given
        let numberOfObjectsToCount = 4
        mock._numberOfObjectsToCount = numberOfObjectsToCount
        
        // when
        let numberOfObjects = try sut.count(TestObject.self, where: (\.$name ?= "Tom"))
        
        // then
        assertThat(mock.countObjectsCalled == true)
        assertThat(numberOfObjects, equalTo(numberOfObjectsToCount))
        assertThat(mock._predicate?.predicateFormat, equalTo("name CONTAINS \"Tom\""))
    }
}
