//
//  FetchedResultsSectionInfoMock.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 05/11/2022.
//

import Foundation
import CoreData

final class FetchedResultsSectionInfoMock: NSFetchedResultsSectionInfo {
    var name: String = ""
    
    var indexTitle: String?
    
    var numberOfObjects: Int = 0
    
    var objects: [Any]?
}
