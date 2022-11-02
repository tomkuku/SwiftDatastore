//
//  ManagedObjectKeyValue.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 02/11/2022.
//

import Foundation
import CoreData

protocol ManagedObjectKeyValue: AnyObject {
    func primitiveValue(forKey key: String) -> Any?
    func setPrimitiveValue(_ value: Any?, forKey key: String)
    func mutableSetValue(forKey key: String) -> NSMutableSet
    func willAccessValue(forKey key: String?)
    func didAccessValue(forKey key: String?)
    func willChangeValue(forKey key: String)
    func didChangeValue(forKey key: String)
    func willChangeValue(forKey inKey: String,
                         withSetMutation inMutationKind: NSKeyValueSetMutationKind,
                         using inObjects: Set<AnyHashable>)
    func didChangeValue(forKey inKey: String,
                        withSetMutation inMutationKind: NSKeyValueSetMutationKind,
                        using inObjects: Set<AnyHashable>)
    func addObserver(_ observer: NSObject,
                     forKeyPath keyPath: String,
                     options: NSKeyValueObservingOptions,
                     context: UnsafeMutableRawPointer?)
    func removeObserver(_ observer: NSObject,
                        forKeyPath keyPath: String,
                        context: UnsafeMutableRawPointer?)
}

extension NSManagedObject: ManagedObjectKeyValue {
}
