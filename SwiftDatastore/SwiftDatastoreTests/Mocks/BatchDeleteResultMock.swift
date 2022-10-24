//
//  BatchDeleteResultMock.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 28/07/2022.
//

import Foundation
import CoreData

@testable import SwiftDatastore

final class BatchDeleteResultMock: NSBatchDeleteResult {
    var _result: Any?
    
    override var result: Any? {
        _result
    }
}
