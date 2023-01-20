//
//  InverseRelationshipDescription.swift
//  SwiftDatastoreTests
//
//  Created by Tomasz Kukułka on 11/01/2023.
//

import Foundation
import CoreData

final class InverseRelationshipDescription: NSRelationshipDescription {
    let invsereObjectName: String
    let inversePropertyName: String
    
    init(invsereObjectName: String, inversePropertyName: String) {
        self.invsereObjectName = invsereObjectName
        self.inversePropertyName = inversePropertyName
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
