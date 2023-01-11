//
//  SwiftDatastore.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 10/09/2022.
//

import Foundation

public final class SwiftDatastore {
    public enum StoringType {
        case app
        case test
    }
    
    private let contextProvider: ManagedObjectContextProvider
    
    public private(set) lazy var sharedViewContext = SwiftDatastoreViewContext(context: contextProvider.viewContext)
    
    public init(storingType: StoringType = .app, storeName: String, datamodelName: String) throws {
        contextProvider = try ManagedObjectContextProvider(storeName: storeName,
                                                           managedObjectModelName: datamodelName,
                                                           destoryStoreDuringCreating: storingType == .test)
    }
    
    public init(storingType: StoringType = .app, storeName: String, datastoreModel: SwiftDatastoreModel) throws {
        contextProvider = try ManagedObjectContextProvider(datastoreModel: datastoreModel,
                                                           storeName: storeName,
                                                           destoryStoreDuringCreating: storingType == .test)
    }
    
    public func createNewContext() -> SwiftDatastoreContext {
        return SwiftDatastoreContext(context: contextProvider.createNewPrivateContext())
    }
}
