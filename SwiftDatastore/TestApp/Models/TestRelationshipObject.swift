//
//  TestRelationshipObject.swift
//  DemoAppCocoaPods
//
//  Created by Kukułka Tomasz on 11/10/2022.
//

import Foundation
import SwiftDatastore

final class TestRelationshipObject: DatastoreObject {
    @Relationship.ToOne(inverse: \.$toOne) var toOne: TestToOneRelationshipObject?
    @Relationship.ToMany(inverse: \.$toOne) var toMany: Set<TestToManyRelationshipObject>
    
    override class var entityName: String {
        "TestRelationshipEntity"
    }
}

final class TestToOneRelationshipObject: DatastoreObject {
    @Relationship.ToOne var toOne: TestRelationshipObject?
}

final class TestToManyRelationshipObject: DatastoreObject {
    @Relationship.ToOne var toOne: TestRelationshipObject?
}
