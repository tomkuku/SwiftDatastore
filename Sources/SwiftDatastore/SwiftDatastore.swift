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
    
    public init(datastoreModel: SwiftDatastoreModel, storeName: String, storingType: StoringType = .app) throws {
        contextProvider = try ManagedObjectContextProvider(managedObjectModel: datastoreModel.managedObjectModel,
                                                           storeName: storeName,
                                                           destoryStoreDuringCreating: storingType == .test)
    }
    
    public func createNewContext() -> SwiftDatastoreContext {
        return SwiftDatastoreContext(context: contextProvider.createNewPrivateContext())
    }
}
