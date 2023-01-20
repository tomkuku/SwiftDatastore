//
//  PropertyDescriptionCreatable.swift
//  SwiftDatastore
//
//  Created by Tomasz Kukułka on 11/01/2023.
//

import Foundation
import CoreData

protocol PropertyDescriptionCreatable {
    func createPropertyDescription() -> NSPropertyDescription
}
