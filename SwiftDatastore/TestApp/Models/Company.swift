//
//  Company.swift
//  DemoApp
//
//  Created by Kukułka Tomasz on 24/07/2022.
//

import Foundation
import SwiftDatastore

final class Company: DatastoreObject {
    @Attribute.Optional var creationDate: Date?
    @Attribute.NotOptional var name: String
    @Attribute.Optional var websideUrl: URL?
    @Relationship.ToMany var employees: Set<Employee>
}
