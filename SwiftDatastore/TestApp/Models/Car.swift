//
//  Car.swift
//  DemoApp
//
//  Created by Kukułka Tomasz on 28/07/2022.
//

import Foundation
import SwiftDatastore

final class Car: DatastoreObject {
    @Attribute.NotOptional var id: UUID
    @Relationship.ToOne var employee: Employee?
    
    override func objectDidCreate() {
        id = UUID()
    }
    
    override class var entityName: String {
        "Car"
    }
}
