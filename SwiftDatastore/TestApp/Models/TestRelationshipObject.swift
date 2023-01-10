//
//  TestRelationshipObject.swift
//  DemoAppCocoaPods
//
//  Created by Kukułka Tomasz on 11/10/2022.
//

import Foundation
import SwiftDatastore

final class TestRelationshipObject: DatastoreObject {
//    @Relationship.ToOne var toOne: TestOptionalObject?
    @Relationship.ToMany var toMany: Set<TestOptionalObject>
    
    override class var entityName: String {
        "TestRelationshipEntity"
    }
}
