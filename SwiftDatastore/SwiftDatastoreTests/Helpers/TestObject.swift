//
//  TestObject.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 16/07/2022.
//
 
import Foundation
import CoreData

@testable import SwiftDatastore

final class MockRelationshipObject: DatastoreObject {
    @Relationship.ToOne("aaaa") var aaaa: TestObject?
}

final class TestObject: DatastoreObject {
    @Attribute.Optional var name: String?
    @Attribute.NotOptional var age: Int
    @Attribute.Optional var uuid: UUID?
    @Attribute.NotOptional var salary: Float
    @Attribute.NotOptional var wight: Float
    @Attribute.NotOptional var height: Double
    @Attribute.NotOptional var isDefective: Bool
    @Attribute.Optional var dateBirth: Date?
    @Relationship.ToOne("toOne", inverse: \MockRelationshipObject.$aaaa) var toOne: MockRelationshipObject?
    
    required init(managedObject: NSManagedObject) {
        super.init(managedObject: managedObject)
    }
}

extension TestObject {
    convenience init() {
        self.init(managedObject: PersistentStoreCoordinatorMock.shared.managedObject)
    }
}
