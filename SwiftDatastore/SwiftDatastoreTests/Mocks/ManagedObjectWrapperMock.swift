//
//  ManagedObjectWrapperMock.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import Foundation
import CoreData

@testable import SwiftDatastore

class ManagedObjectWrapperMock: ManagedObjectWrapperLogic {
    var _managedObject = PersistentStoreCoordinatorMock.shared.managedObject
    var _value: Any?
    var _mutableSet = NSMutableSet()
    
    var getValueCalled = false
    var setValueCalled = false
    var mutableSetValueCalled = false
    var addObserverCalled = false
    var removeObserverCalled = false
    
    var object: NSManagedObject {
        _managedObject
    }
    
    func getValue<T>(forKey key: String) -> T? {
        getValueCalled = true
        return _value as? T
    }
    
    func set(_ value: Any?, forKey key: String) {
        setValueCalled = true
        _value = value
    }
    
    func mutableSetValue(forKey key: String) -> NSMutableSet {
        mutableSetValueCalled = true
        return _mutableSet
    }
    
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions) {
        addObserverCalled = true
    }
    
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        removeObserverCalled = true
    }
}
