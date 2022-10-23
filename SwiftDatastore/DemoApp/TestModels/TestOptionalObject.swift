//
//  TestOptionalObject.swift
//  DemoApp
//
//  Created by Kukułka Tomasz on 11/10/2022.
//

import Foundation
import SwiftDatastore

final class TestOptionalObject: DatastoreObject {
    @Attribute.Optional var bool: Bool?
    @Attribute.Optional var data: Data?
    @Attribute.Optional var date: Date?
    @Attribute.Optional var double: Double?
    @Attribute.Optional var float: Float?
    @Attribute.Optional var id: UUID?
    @Attribute.Optional var int: Int?
    @Attribute.Optional var string: String?
    @Attribute.Optional var url: URL?
    
    override class var entityName: String {
        "TestOptionalEntity"
    }
}
