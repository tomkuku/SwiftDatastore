//
//  SwiftDatastoreError.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 09/10/2022.
//

import Foundation

public enum SwiftDatastoreError {
    
    public struct EntityNotFound: Error, LocalizedError {
        let entityName: String
        
        public var errorDescription: String? {
            "Entity with name: \(entityName) not found!"
        }
        
        init(_ name: String) {
            self.entityName = name
        }
    }
    
    public struct ModelFileNotFound: Error, LocalizedError {
        let modelName: String
        
        public var errorDescription: String? {
            "ManagedObjectModel's with name: \(modelName) not found!"
        }
        
        init(_ name: String) {
            self.modelName = name
        }
    }
}
