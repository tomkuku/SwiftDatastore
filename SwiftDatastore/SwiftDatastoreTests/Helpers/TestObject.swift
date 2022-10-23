//
//  TestObject.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 16/07/2022.
//
 
import Foundation
import CoreData

@testable import SwiftDatastore

final class TestObject: DatastoreObject {
    @Attribute.Optional var name: String?
    @Attribute.NotOptional var age: Int
    @Attribute.Optional var uuid: UUID?
    @Attribute.NotOptional var salary: Float
    @Attribute.NotOptional var wight: Float
    @Attribute.NotOptional var height: Double
    @Attribute.NotOptional var isDefective: Bool
    @Attribute.Optional var dateBirth: Date?
    
    required init(managedObjectWrapper: ManagedObjectWrapperLogic) {
        super.init(managedObjectWrapper: managedObjectWrapper)
    }
}

extension TestObject {
    convenience init() {
        self.init(managedObjectWrapper: ManagedObjectWrapperMock())
    }
}
