//
//  DatastoreContextClosureTests.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 13/09/2022.
//

import XCTest
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
        numberOfDeletedObjects = try sut.deleteMany(TestObject.self, where: \.$age == 34)

        // then
        XCTAssertEqual(numberOfDeletedObjects, 0)
        XCTAssertEqual(mock._batchDeleteRequestResultType, .resultTypeObjectIDs)
        XCTAssertEqual(mock._predicate?.predicateFormat, "age == 34")
        XCTAssertTrue(mock.executeRequestCalled)
        XCTAssertFalse(mock.mergeChangesCalled)
        XCTAssertNil(mock._objectIDsToMerge)
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
        XCTAssertEqual(numberOfDeletedObjects, objectIDsToDelete.count)
        XCTAssertEqual(mock._batchDeleteRequestResultType, .resultTypeObjectIDs)
        XCTAssertEqual(mock._predicate?.predicateFormat, "age >= 44")
        XCTAssertTrue(mock.executeRequestCalled)
        XCTAssertTrue(mock.mergeChangesCalled)
        XCTAssertEqual(mock._objectIDsToMerge?.count, objectIDsToDelete.count)
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
        XCTAssertEqual(numberOfUpdatedObjects, 0)
        XCTAssertTrue(mock.executeRequestCalled)
        XCTAssertEqual(mock._batchUpdateRequestResultType, .updatedObjectIDsResultType)
        XCTAssertEqual(mock._predicate?.predicateFormat, "isDefective != 0")
        XCTAssertEqual(mock._batchUpdateRequestPropertiesToUpdate?.count, 2)
        XCTAssertFalse(mock.mergeChangesCalled)
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
        XCTAssertEqual(numberOfUpdatedObjects, objectIDsToUpdate.count)
        XCTAssertTrue(mock.executeRequestCalled)
        XCTAssertEqual(mock._batchUpdateRequestResultType, .updatedObjectIDsResultType)
        XCTAssertEqual(mock._predicate?.predicateFormat, "height > 178.5")
        XCTAssertEqual(mock._batchUpdateRequestPropertiesToUpdate?.count, 2)
        XCTAssertTrue(mock.mergeChangesCalled)
        XCTAssertEqual(mock._objectIDsToMerge?.count, objectIDsToUpdate.count)
    }

    // MARK: CreateObject
    func test_createObject() throws {
        // when
        let _: TestObject = try sut.createObject()

        // then
        XCTAssertTrue(mock.getEntityDescriptionCalled)
        XCTAssertTrue(mock.createManagedObjectCalled)
        XCTAssertTrue(mock.obtainPermanentIDsCalled)
    }

    // MARK: DeleteObject
    func test_deleteObject() {
        // given
        let objectDelete = TestObject()

        // when
        sut.deleteObject(objectDelete)

        // then
        XCTAssertTrue(mock.deleteCalled)
    }

    // MARK: Count
    func test_count_fromEmptyStore() throws {
        // when
        let numberOfObjects = try sut.count(TestObject.self, where: \.$age == 34)

        // then
        XCTAssertTrue(mock.countObjectsCalled)
        XCTAssertEqual(numberOfObjects, 0)
        XCTAssertEqual(mock._predicate?.predicateFormat, "age == 34")
    }

    func test_count_fromNotEmptyStore() throws {
        // given
        let numberOfObjectsToCount = 4
        mock._numberOfObjectsToCount = numberOfObjectsToCount

        // when
        let numberOfObjects = try sut.count(TestObject.self, where: \.$age == 34)
        
        // then
        XCTAssertTrue(mock.countObjectsCalled)
        XCTAssertEqual(numberOfObjects, numberOfObjectsToCount)
        XCTAssertEqual(mock._predicate?.predicateFormat, "age == 34")
    }

    // MARK: Convert
    func test_convertExistingObject() throws {
        let entity = PersistentStoreCoordinatorMock.shared.entityDescription        
        
        // given
        let objectToConvert = TestObject()

        // when
        let _ = try sut.convert(existingObject: objectToConvert)

        // then
        XCTAssertTrue(mock.existingObjectCalled)
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
        let fetchedProperties = try sut.fetch(TestObject.self,
                                              properties: [.init(\.$name), .init(\.$age)],
                                              where: \.$age > 30,
                                              orderBy: [.desc(\.$salary)],
                                              offset: 18,
                                              limit: 99)
        
        // then
        XCTAssertEqual(mock._propertiesToFetch?.count, 2)
        XCTAssertEqual(mock._propertiesToFetch?.first, nameKey)
        XCTAssertEqual(mock._sorts, [NSSortDescriptor(key: "salary", ascending: false)])
        XCTAssertEqual(mock._predicate?.predicateFormat, "age > 30")
        XCTAssertEqual(mock._fetchOffset, 18)
        XCTAssertEqual(mock._fetchLimit, 99)
        XCTAssertEqual(fetchedProperties.count, 2)
        XCTAssertEqual(fetchedProperties.first?.keys.count, 2)
        XCTAssertEqual(fetchedProperties.first?[nameKey] as? String, "Tom")
        XCTAssertNil(fetchedProperties.last?[ageKey] as? Int)
    }

    // MARK: RevertChanges
    func test_revertChanges() {
        // when
        sut.revertChanges()

        // then
        XCTAssertTrue(mock.rollbackCalled)
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
        XCTAssertTrue(mock.saveCalled)
        XCTAssertEqual(gotSavedChanges.insertedObjects.count, 0)
        XCTAssertEqual(gotSavedChanges.updatedObjects.count, 1)
        XCTAssertEqual(gotSavedChanges.deletedObjects.count, 2)
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
        XCTAssertTrue(mock.existingObjectCalled)
        XCTAssertTrue(mock.refreshCalled)
    }
}
