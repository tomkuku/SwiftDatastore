//
//  TestNotOptionalObject.swift
//  DemoApp
//
//  Created by Kukułka Tomasz on 11/10/2022.
//

import Foundation
import SwiftDatastore

final class TestNotOptionalObject: DatastoreObject {
    @Attribute.NotOptional var bool: Bool
    @Attribute.NotOptional var data: Data
    @Attribute.NotOptional var date: Date
    @Attribute.NotOptional var double: Double
    @Attribute.NotOptional var float: Float
    @Attribute.NotOptional var id: UUID
    @Attribute.NotOptional var int: Int
    @Attribute.NotOptional var string: String
    @Attribute.NotOptional var url: URL
    
    override class var entityName: String {
        "TestNotOptionalEntity"
    }
}
