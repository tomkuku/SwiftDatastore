//
//  SwiftDatastoreModelTests.swift
//  SwiftDatastoreTests
//
//  Created by Tomasz Kukułka on 11/01/2023.
//

import XCTest

@testable import SwiftDatastore

enum MockError: Error {
    case test
}

final class SwiftDatastoreModelTests: XCTestCase {
    final class FirstObject: DatastoreObject {
        @Relationship.ToOne(inverse: \SecondObject.$toOne) var toOne: SecondObject?
    }

    final class SecondObject: DatastoreObject {
        @Relationship.ToOne var toOne: FirstObject?
    }
    
    func test_createModel() throws {
        // when
        let sut = SwiftDatastoreModel(from: FirstObject.self, SecondObject.self)
        let model = sut.createModel()
        
        // then
        XCTAssertEqual(model.entities.count, 2)
        
        guard let firstObjectEntity = model.entitiesByName["FirstObject"] else {
            XCTFail("firstObjectEntity is nil")
            throw MockError.test
        }
        
        guard let toOneRelationship = firstObjectEntity.relationshipsByName["toOne"] else {
            XCTFail("toOneRelationship is nil")
            throw MockError.test
        }
        
        XCTAssertEqual(toOneRelationship.destinationEntity?.name, "SecondObject")
        XCTAssertFalse(toOneRelationship.isToMany)
        XCTAssertEqual(toOneRelationship.inverseRelationship?.name, "toOne")
    }
}
