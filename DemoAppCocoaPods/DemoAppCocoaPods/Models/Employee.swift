//
//  Employee.swift
//  DemoApp
//
//  Created by Kukułka Tomasz on 24/07/2022.
//

import Foundation
import SwiftDatastore

enum Position: Int {
    case developer
    case userInterfaceDesigner
    case productOwner
}

final class Employee: DatastoreObject {    
    @Attribute.NotOptional var id: UUID
    @Attribute.Optional var isInvalid: Bool?
    @Attribute.Enum var position: Position?
    @Attribute.Optional var salary: Float?
    @Attribute.Optional var avatarImageData: Data?
    @Relationship.ToOne var company: Company?
    
    override func objectDidCreate() {
        id = UUID()
    }
}
