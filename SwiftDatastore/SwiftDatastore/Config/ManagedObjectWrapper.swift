//
//  ManagedObject.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import Foundation
import CoreData

public protocol ManagedObjectWrapperLogic {
    var object: NSManagedObject { get }
    
    func getValue<T>(forKey key: String) -> T?
    func set(_ value: Any?, forKey key: String)
    func mutableSetValue(forKey key: String) -> NSMutableSet
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions)
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String)
}

public class ManagedObjectWrapper: ManagedObjectWrapperLogic {
        
    public var object: NSManagedObject {
        managedObject
    }
    
    private var managedObject: NSManagedObject!
    
    internal init() {
        // Internal init
    }
    
    internal init(managedObject: NSManagedObject) {
        self.managedObject = managedObject
    }
    
    public func getValue<T>(forKey key: String) -> T? {
        defer {
            managedObject.didAccessValue(forKey: key)
        }
        managedObject.willAccessValue(forKey: key)
        return managedObject.primitiveValue(forKey: key) as? T
    }
    
    public func set(_ value: Any?, forKey key: String) {
        defer {
            managedObject.didChangeValue(forKey: key)
        }
        managedObject.willChangeValue(forKey: key)
        guard let value = value else {
            managedObject.setPrimitiveValue(nil, forKey: key)
            return
        }
        managedObject.setPrimitiveValue(value, forKey: key)
    }
    
    public func mutableSetValue(forKey key: String) -> NSMutableSet {
        managedObject.mutableSetValue(forKey: key)
    }
    
    public func addObserver(_ observer: NSObject,
                            forKeyPath keyPath: String,
                            options: NSKeyValueObservingOptions) {
        managedObject.addObserver(observer, forKeyPath: keyPath, options: options, context: nil)
    }
    
    public func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        managedObject.removeObserver(observer, forKeyPath: keyPath, context: nil)
    }
}
