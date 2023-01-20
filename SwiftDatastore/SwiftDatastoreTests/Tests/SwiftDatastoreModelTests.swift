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
    final class TestModelObject: DatastoreObject {
        @Attribute.Optional var optional: Float?
        @Attribute.NotOptional var notOptional: UUID
        @Attribute.Enum var `enum`: TestEnum?
        
        @Relationship.ToOne(inverse: \ToOneRelationshipObject.$inverseToOne)
        var toOne: ToOneRelationshipObject?
        @Relationship.ToMany(inverse: \ToManyRelationshipObject.$inverseToMany)
        var toMany: Set<ToManyRelationshipObject>
        @Relationship.ToMany.Ordered(inverse: \ToManyOrderedRelationshipObject.$inverseToManyOrdered)
        var toManyOrdered: [ToManyOrderedRelationshipObject]
    }

    final class ToOneRelationshipObject: DatastoreObject {
        @Relationship.ToOne var inverseToOne: TestModelObject?
    }
    
    final class ToManyRelationshipObject: DatastoreObject {
        @Relationship.ToOne var inverseToMany: TestModelObject?
    }
    
    final class ToManyOrderedRelationshipObject: DatastoreObject {
        @Relationship.ToOne var inverseToManyOrdered: TestModelObject?
    }
    
    // To keep mom's entities in memory due NSEntityDescriptions is unowned(unsafe) and is deallocated immediately
    var mom: NSManagedObjectModel!
    var entityDescription: NSEntityDescription!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let sut = SwiftDatastoreModel(from: TestModelObject.self, ToOneRelationshipObject.self, ToManyRelationshipObject.self, ToManyOrderedRelationshipObject.self)
        mom = sut.managedObjectModel
        
        guard let entityDescription = mom.entitiesByName[TestModelObject.entityName] else {
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
        let attribute = entityDescription.attributesByName["optional"]
        XCTAssertEqual(attribute?.isOptional, true)
        XCTAssertEqual(attribute?.attributeType, .floatAttributeType)
    }
    
    // MARK: NotOptional Attribute
    func test_notOptionalAttribute() throws {
        let attribute = entityDescription.attributesByName["notOptional"]
        XCTAssertEqual(attribute?.isOptional, false)
        XCTAssertEqual(attribute?.attributeType, .UUIDAttributeType)
    }
    
    // MARK: Enum Attribute
    func test_enumAttribute() throws {
        let attribute = entityDescription.attributesByName["enum"]
        XCTAssertEqual(attribute?.isOptional, true)
        XCTAssertEqual(attribute?.attributeType, .integer64AttributeType)
    }
    
    // MARK: ToOne Relationship
    func test_toOneRelationship() throws {
        // when
        let relationship = entityDescription.relationshipsByName["toOne"]
        let inverseEntity = mom.entitiesByName[ToOneRelationshipObject.entityName]
        let inverseRelationship = inverseEntity?.relationshipsByName["inverseToOne"]
        
        // then
        XCTAssertEqual(relationship?.destinationEntity?.name, ToOneRelationshipObject.entityName)
        XCTAssertEqual(relationship?.isToMany, false)
        XCTAssertEqual(relationship?.isOptional, true)
        XCTAssertEqual(relationship?.inverseRelationship?.name, "inverseToOne")
        
        XCTAssertEqual(inverseRelationship?.destinationEntity?.name, TestModelObject.entityName)
        XCTAssertEqual(inverseRelationship?.inverseRelationship?.name, "toOne")
    }
    
    // MARK: ToMany Relationship
    func test_toManyRelationship() throws {
        // when
        let relationship = entityDescription.relationshipsByName["toMany"]
        let inverseEntity = mom.entitiesByName[ToManyRelationshipObject.entityName]
        let inverseRelationship = inverseEntity?.relationshipsByName["inverseToMany"]
        
        // then
        XCTAssertEqual(relationship?.destinationEntity?.name, ToManyRelationshipObject.entityName)
        XCTAssertEqual(relationship?.isToMany, true)
        XCTAssertEqual(relationship?.isOptional, false)
        XCTAssertEqual(relationship?.isOrdered, false)
        XCTAssertEqual(relationship?.inverseRelationship?.name, "inverseToMany")
        
        XCTAssertEqual(inverseRelationship?.destinationEntity?.name, TestModelObject.entityName)
        XCTAssertEqual(inverseRelationship?.inverseRelationship?.name, "toMany")
    }
    
    // MARK: ToManyOrdered Relationship
    func test_toManyOrderedRelationship() throws {
        // when
        let relationship = entityDescription.relationshipsByName["toManyOrdered"]
        let inverseEntity = mom.entitiesByName[ToManyOrderedRelationshipObject.entityName]
        let inverseRelationship = inverseEntity?.relationshipsByName["inverseToManyOrdered"]
        
        // then
        XCTAssertEqual(relationship?.destinationEntity?.name, ToManyOrderedRelationshipObject.entityName)
        XCTAssertEqual(relationship?.isToMany, true)
        XCTAssertEqual(relationship?.isOptional, false)
        XCTAssertEqual(relationship?.isOrdered, true)
        XCTAssertEqual(relationship?.inverseRelationship?.name, "inverseToManyOrdered")
        
        XCTAssertEqual(inverseRelationship?.destinationEntity?.name, TestModelObject.entityName)
        XCTAssertEqual(inverseRelationship?.inverseRelationship?.name, "toManyOrdered")
    }
}
