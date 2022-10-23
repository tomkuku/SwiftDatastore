//
//  EntityAttribute.swift
//  DatabaseApi
//
//  Created by Tomasz Kukułka on 10/03/2022.
//

import Foundation
import CoreData

public protocol EntityPropertyKeyPath: AnyObject {
    associatedtype KeyPathType
    
    var key: String { get set }
}
