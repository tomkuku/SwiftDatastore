//
//  Person.swift
//  CocoaPodsApp
//
//  Created by Kukułka Tomasz on 24/10/2022.
//

import Foundation
import SwiftDatastore

final class Person: DatastoreObject {
    @Attribute.Optional var name: String?
}
