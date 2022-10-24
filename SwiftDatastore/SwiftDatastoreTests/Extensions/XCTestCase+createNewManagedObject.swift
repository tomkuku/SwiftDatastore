//
//  XCTestCase+createNewManagedObject.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 03/08/2022.
//

import Foundation
import XCTest
import CoreData

extension XCTestCase {
    func createNewManagedObject() -> NSManagedObject {
        NSManagedObject(entity: PersistentStoreCoordinatorMock.shared.entityDescription,
                        insertInto: PersistentStoreCoordinatorMock.shared.mocMock)
    }
}
