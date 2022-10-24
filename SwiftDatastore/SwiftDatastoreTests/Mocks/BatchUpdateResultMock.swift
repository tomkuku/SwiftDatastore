//
//  BatchUpdateResultMock.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 06/08/2022.
//

import Foundation
import CoreData

class BatchUpdateRequestMock: NSBatchUpdateResult {
    
    var _result: [NSManagedObjectID] = []
    
    override var result: Any? {
        _result
    }
}
