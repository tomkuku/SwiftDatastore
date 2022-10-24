//
//  AsynchronousFetchRequest.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 03/08/2022.
//

import Foundation
import CoreData

class AsynchronousFetchRequest {
    func create(
        fetchRequest: NSFetchRequest<NSManagedObject>,
        completion: ((NSAsynchronousFetchResult<NSManagedObject>) -> Void)?
    ) -> NSAsynchronousFetchRequest<NSManagedObject> {
        NSAsynchronousFetchRequest(fetchRequest: fetchRequest, completionBlock: completion)
    }
}
