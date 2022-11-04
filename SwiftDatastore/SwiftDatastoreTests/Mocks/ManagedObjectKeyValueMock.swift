//
//  ManagedObjectKeyValueMock.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 31/10/2022.
//

import Foundation

@testable import SwiftDatastore

class ManagedObjectKeyValueMock: ManagedObjectKeyValue {
    var _primitiveValue: Any?
    var _mutableSet = NSMutableSet()
    var _mutableOrderedSet = NSMutableOrderedSet()
    
    var primitiveValueCalled = false
    var setPrimitiveValueCalled = false
    var mutableSetValueCalled = false
    var willAccessValueCalled = false
    var didAccessValueCalled = false
    var willChangeValueCalled = false
    var didChangeValueCalled = false
    var willChangeValueSetCalled = false
    var didChangeValueSetCalled = false
    var addObserverCalled = false
    var removeObserverCalled = false
    var mutableOrderedSetValueCalled = false
    var willChangeValueOrderedSetCalled = false
    var didChangeValueOrderedSetCalled = false
    
    func primitiveValue(forKey key: String) -> Any? {
        primitiveValueCalled = true
        return _primitiveValue
    }
    
    func setPrimitiveValue(_ value: Any?, forKey key: String) {
        _primitiveValue = value
        setPrimitiveValueCalled = true
    }
    
    func mutableSetValue(forKey key: String) -> NSMutableSet {
        mutableSetValueCalled = true
        return _mutableSet
    }
    
    func mutableOrderedSetValue(forKey key: String) -> NSMutableOrderedSet {
        mutableOrderedSetValueCalled = true
        return _mutableOrderedSet
    }
    
    func willAccessValue(forKey key: String?) {
        willAccessValueCalled = true
    }
    
    func didAccessValue(forKey key: String?) {
        didAccessValueCalled = true
    }
    
    func willChangeValue(forKey key: String) {
        willChangeValueCalled = true
    }
    
    func didChangeValue(forKey key: String) {
        didChangeValueCalled = true
    }
    
    func willChangeValue(forKey inKey: String,
                         withSetMutation inMutationKind: NSKeyValueSetMutationKind,
                         using inObjects: Set<AnyHashable>) {
        willChangeValueSetCalled = true
    }
    
    func didChangeValue(forKey inKey: String,
                        withSetMutation inMutationKind: NSKeyValueSetMutationKind,
                        using inObjects: Set<AnyHashable>) {
        didChangeValueSetCalled = true
    }
    
    func willChange(_ changeKind: NSKeyValueChange,
                    valuesAt indexes: IndexSet,
                    forKey key: String) {
        willChangeValueOrderedSetCalled = true
    }
    
    func didChange(_ changeKind: NSKeyValueChange,
                   valuesAt indexes: IndexSet,
                   forKey key: String) {
        didChangeValueOrderedSetCalled = true
    }
    
    func addObserver(_ observer: NSObject,
                     forKeyPath keyPath: String,
                     options: NSKeyValueObservingOptions,
                     context: UnsafeMutableRawPointer?) {
        addObserverCalled = true
    }
    
    func removeObserver(_ observer: NSObject,
                        forKeyPath keyPath: String,
                        context: UnsafeMutableRawPointer?) {
        removeObserverCalled = true
    }
}
