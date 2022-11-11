//
//  SwiftDatastoreError.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 09/10/2022.
//

import Foundation

public enum SwiftDatastoreError: Error, LocalizedError {
    case entityNotFound
    case managedObjectModelNotFound
    
    public var errorDescription: String? {
        switch self {
        case .entityNotFound:
            return "Entity with name not found!"
        case .managedObjectModelNotFound:
            return "ManagedObjectModel's name not found!"
        }
    }
}
