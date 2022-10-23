//
//  MomController.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 10/10/2022.
//

import Foundation
import CoreData

class MomController {
    func createModel(contentsOf url: URL) -> NSManagedObjectModel? {
        NSManagedObjectModel(contentsOf: url)
    }
}
