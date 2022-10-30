//
//  DatastoreContext.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 20/09/2022.
//

import Foundation
import CoreData

public final class SwiftDatastoreContext {
    // MARK: Propertes
    private let closure: Closure
    private let context: ManagedObjectContext
    
    init(context: ManagedObjectContext) {
        self.context = context
        closure = Closure(context: context)
    }
    
    // MARK: Perform
    public func perform(block: @escaping (_ context: Closure) throws -> Void,
                        success: (() -> Void)? = nil,
                        failure: ((_  error: Error) -> Void)? = nil) {
        context.perform {
            do {
                try block(self.closure)
                success?()
            } catch {
                failure?(error)
                return
            }
        }
    }
    
    // MARK: Perform Completion
    public func perform(block: @escaping (_ context: Closure) -> Void,
                        completion: (() -> Void)? = nil) {
        context.perform {
            block(self.closure)
            completion?()
        }
    }
    
    // MARK: CreateNewChildContext
    public func createNewChildContext() -> SwiftDatastoreContext {
        let childManagedObjectContext = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childManagedObjectContext.parent = context
        return SwiftDatastoreContext(context: childManagedObjectContext)
    }
}
