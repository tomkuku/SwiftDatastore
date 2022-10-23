//
//  DatastoreContextClosureTests.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 13/09/2022.
//

import XCTest
import Hamcrest
import CoreData

@testable import SwiftDatastore

class DatastoreContextClosureTests: XCTestCase {
    
    // MARK: Properties
    typealias SutType = SwiftDatastoreContext.Closure
    
    var sut: SutType!
    var mock: ManagedObjectContextMock!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        mock = ManagedObjectContextMock(concurrencyType: .privateQueueConcurrencyType)
        sut = SutType(context: mock)
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    // MARK: DeleteMany
    func test_deleteMany_withoutObjectsToDelete() throws {
        // given
        let batchDeleteResultMock = BatchDeleteResultMock()
        mock._batchDeleteResultMock = batchDeleteResultMock

        var numberOfDeletedObjects = Int.max

        // when
        numberOfDeletedObjects = try sut.deleteMany(TestObject.self, where: (\.$name ^= "e"))

        // then
        assertThat(numberOfDeletedObjects, equalTo(0))
        assertThat(mock._batchDeleteRequestResultType, equalTo(.resultTypeObjectIDs))
        assertThat(mock._predicate?.predicateFormat, equalTo("name BEGINSWITH \"e\""))
        assertThat(mock.executeRequestCalled == true)
        assertThat(mock.mergeChangesCalled == false)
        assertThat(mock._objectIDsToMerge, nilValue())
    }

    func test_deleteMany_withObjectsToDelete() throws {
        // given
        let objectIDsToDelete = [NSManagedObjectID(), NSManagedObjectID(), NSManagedObjectID()]

        let batchDeleteResultMock = BatchDeleteResultMock()
        batchDeleteResultMock._result = objectIDsToDelete

        mock._batchDeleteResultMock = batchDeleteResultMock

        var numberOfDeletedObjects = Int.max

        // when
        numberOfDeletedObjects = try sut.deleteMany(TestObject.self, where: (\.$age >= 44))

        // then
        assertThat(numberOfDeletedObjects, equalTo(objectIDsToDelete.count))
        assertThat(mock._batchDeleteRequestResultType, equalTo(.resultTypeObjectIDs))
        assertThat(mock._predicate?.predicateFormat, equalTo("age >= 44"))
        assertThat(mock.executeRequestCalled == true)
        assertThat(mock.mergeChangesCalled == true)
        assertThat(mock._objectIDsToMerge?.count, equalTo(objectIDsToDelete.count))
    }

    // MARK: UpdateMany
    func test_updateMany_withoutObjectsToUpdate() throws {
        // given
        let batchUpdateResultMock = BatchUpdateRequestMock()

        batchUpdateResultMock._result = []

        mock._batchUpdateResultMock = batchUpdateResultMock

        var numberOfUpdatedObjects = Int.max

        // when
        numberOfUpdatedObjects = try sut.updateMany(TestObject.self,
                                                where: (\.$isDefective != false),
                                                propertiesToUpdate: [.init(\.$isDefective, false),
                                                                     .init(\.$name, "Jim")])

        // then
        assertThat(numberOfUpdatedObjects, equalTo(0))
        assertThat(mock.executeRequestCalled == true)
        assertThat(mock._batchUpdateRequestResultType, equalTo(.updatedObjectIDsResultType))
        assertThat(mock._predicate?.predicateFormat, equalTo("isDefective != 0"))
        assertThat(mock._batchUpdateRequestPropertiesToUpdate?.count, equalTo(2))
        assertThat(mock.mergeChangesCalled == false)
    }

    func test_updateMany_withObjectsToUpdate() throws {
        // given
        let batchUpdateResultMock = BatchUpdateRequestMock()
        let objectIDsToUpdate = [NSManagedObjectID(), NSManagedObjectID(), NSManagedObjectID()]

        batchUpdateResultMock._result = objectIDsToUpdate

        mock._batchUpdateResultMock = batchUpdateResultMock

        var numberOfUpdatedObjects = 0

        // when
        numberOfUpdatedObjects = try sut.updateMany(TestObject.self,
                                                where: (\.$height > 178.5),
                                                propertiesToUpdate: [.init(\.$age, 22),
                                                                     .init(\.$name, "Jim")])

        // then
        assertThat(numberOfUpdatedObjects, equalTo(objectIDsToUpdate.count))
        assertThat(mock.executeRequestCalled == true)
        assertThat(mock._batchUpdateRequestResultType, equalTo(.updatedObjectIDsResultType))
        assertThat(mock._predicate?.predicateFormat, equalTo("height > 178.5"))
        assertThat(mock._batchUpdateRequestPropertiesToUpdate?.count, equalTo(2))
        assertThat(mock.mergeChangesCalled == true)
        assertThat(mock._objectIDsToMerge?.count, equalTo(objectIDsToUpdate.count))
    }

    // MARK: CreateObject
    func test_createObject() throws {
        // when
        let _: TestObject = try sut.createObject()

        // then
        assertThat(mock.getEntityDescriptionCalled == true)
        assertThat(mock.createManagedObjectCalled == true)
        assertThat(mock.obtainPermanentIDsCalled == true)
    }

    // MARK: DeleteObject
    func test_deleteObject() {
        // given
        let objectDelete = TestObject()

        // when
        sut.deleteObject(objectDelete)

        // then
        assertThat(mock.deleteCalled == true)
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

    // MARK: Convert
    func test_convertExistingObject() throws {
        // given
        let objectToConvert = TestObject()

        // when
        let _ = try sut.convert(existingObject: objectToConvert)

        // then
        assertThat(mock.existingObjectCalled == true)
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

    // MARK: FetchProperties
    func test_fetchProperties() throws {
        // given
        let nameKey = "name"
        let ageKey = "age"

        let dictornay1 = NSMutableDictionary()
        dictornay1[nameKey] = "Tom"
        dictornay1[ageKey] = 21

        let dictornay2 = NSMutableDictionary()
        dictornay2[nameKey] = "Jane"
        dictornay2[ageKey] = nil

        mock._fetchRequestResult = [dictornay1, dictornay2]

        // when
        let fetchedProperties = try sut.fetchProperties(TestObject.self,
                                                    where: \.$age > 30,
                                                    orderBy: [.desc(\.$salary)],
                                                    offset: 18,
                                                    limit: 99,
                                                    propertiesToFetch: [.init(\.$name),
                                                                        .init(\.$age)])

        // then
        assertThat(mock._propertiesToFetch?.count, equalTo(2))
        assertThat(mock._propertiesToFetch?.first, equalTo(nameKey))
        assertThat(mock._sorts, equalTo([NSSortDescriptor(key: "salary", ascending: false)]))
        assertThat(mock._predicate?.predicateFormat, equalTo("age > 30"))
        assertThat(mock._fetchOffset, equalTo(18))
        assertThat(mock._fetchLimit, equalTo(99))
        assertThat(fetchedProperties.count, equalTo(2))
        assertThat(fetchedProperties.first?.keys.count, equalTo(2))
        assertThat(fetchedProperties.first?[nameKey] as? String, equalTo("Tom"))
        assertThat(fetchedProperties.last?[ageKey] as? Int, nilValue())
    }

    // MARK: RevertChanges
    func test_revertChanges() {
        // when
        sut.revertChanges()

        // then
        assertThat(mock.rollbackCalled == true)
    }

    // MARK: SaveChanges
    func test_saveChanges() throws {
        // given
        mock._insertedObjects = []
        mock._updatedObjects = [createNewManagedObject()]
        mock._deletedObjects = [createNewManagedObject(), createNewManagedObject()]
        
        // when
        let gotSavedChanges = try sut.saveChanges()
        
        // then
        assertThat(mock.saveCalled == true)
        assertThat(gotSavedChanges.insertedObjects.count, equalTo(0))
        assertThat(gotSavedChanges.updatedObjects.count, equalTo(1))
        assertThat(gotSavedChanges.deletedObjects.count, equalTo(2))
    }
    
    // MARK: RefreshChanges
    func test_refresh() {
        // given
        let updatedObjects = [createNewManagedObject()]
        let deletedObjects = [createNewManagedObject(), createNewManagedObject()]
        
        let changes = SwiftDatastoreSavedChanges(insertedObjects: [],
                                                 updatedObjects: Set(updatedObjects),
                                                 deletedObjects: Set(deletedObjects))
        
        // when
        sut.refresh(using: changes)
        
        // then
        assertThat(mock.existingObjectCalled == true)
        assertThat(mock.refreshCalled == true)
    }
}
