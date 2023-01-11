//
//  SwiftDatastoreModelTests.swift
//  SwiftDatastoreTests
//
//  Created by Tomasz Kukułka on 11/01/2023.
//

import XCTest
import CoreData

@testable import SwiftDatastore

enum MockError: Error {
    case test
}

final class SwiftDatastoreModelTests: XCTestCase {
    final class TestStoreObject: DatastoreObject {
        @Attribute.Optional var optional: Float?
        @Attribute.NotOptional var notOptional: UUID
        @Attribute.Enum var `enum`: TestEnum?
        @Relationship.ToOne(inverse: \DummyRelationshipObject.$toOne) var toOne: DummyRelationshipObject?
    }

    final class DummyRelationshipObject: DatastoreObject {
        @Relationship.ToOne var toOne: TestStoreObject?
    }
    
    // To keep mom's entities in memory due NSEntityDescriptions is unowned(unsafe) and is deallocated immediately
    var mom: NSManagedObjectModel!
    var entityDescription: NSEntityDescription!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let sut = SwiftDatastoreModel(from: TestStoreObject.self, DummyRelationshipObject.self)
        mom = sut.managedObjectModel
        
        guard let entityDescription = mom.entitiesByName[TestStoreObject.entityName] else {
            XCTFail("entityDescription is nil")
            throw MockError.test
        }
        
        self.entityDescription = entityDescription
    }
    
    override func tearDown() {
        entityDescription = nil
        super.tearDown()
    }
    
    // MARK: Optional Attribute
    func test_optionalAttribute() throws {
        guard let attribute = entityDescription.attributesByName["optional"] else {
            XCTFail("optionalAttribute is nil")
            throw MockError.test
        }
        
        XCTAssertTrue(attribute.isOptional)
        XCTAssertEqual(attribute.attributeType, .floatAttributeType)
    }
    
    // MARK: NotOptional Attribute
    func test_notOptionalAttribute() throws {
        guard let attribute = entityDescription.attributesByName["notOptional"] else {
            XCTFail("optionalAttribute is nil")
            throw MockError.test
        }
        
        XCTAssertFalse(attribute.isOptional)
        XCTAssertEqual(attribute.attributeType, .UUIDAttributeType)
    }
    
    // MARK: Enum Attribute
    func test_enumAttribute() throws {
        guard let attribute = entityDescription.attributesByName["enum"] else {
            XCTFail("attribute is nil")
            throw MockError.test
        }
        
        XCTAssertTrue(attribute.isOptional)
        XCTAssertEqual(attribute.attributeType, .integer64AttributeType)
    }
    
    // MARK: ToOne Relationship
    func test_toOneRelationship() throws {
        guard let relationship = entityDescription.relationshipsByName["toOne"] else {
            XCTFail("toOneRelationship is nil")
            throw MockError.test
        }
        
        XCTAssertEqual(relationship.destinationEntity?.name, DummyRelationshipObject.entityName)
        XCTAssertFalse(relationship.isToMany)
        XCTAssertTrue(relationship.isOptional)
        XCTAssertEqual(relationship.inverseRelationship?.name, "toOne")
        
        guard let dummyRelationshipObject = mom.entitiesByName[DummyRelationshipObject.entityName] else {
            XCTFail("dummyRelationshipObject is nil")
            throw MockError.test
        }
        
        guard let relationship = dummyRelationshipObject.relationshipsByName["toOne"] else {
            XCTFail("toOneRelationship is nil")
            throw MockError.test
        }
        
        XCTAssertEqual(relationship.destinationEntity?.name, TestStoreObject.entityName)
        XCTAssertEqual(relationship.inverseRelationship?.name, "toOne")
    }
}
