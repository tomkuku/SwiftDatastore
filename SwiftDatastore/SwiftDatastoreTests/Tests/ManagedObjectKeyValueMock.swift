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
    
    var primitiveValueCalled = false
    var setPrimitiveValueCalled = false
    var mutableSetValueCalled = false
    var willAccessValueCalled = false
    var didAccessValueCalled = false
    var willChangeValueCalled = false
    var didChangeValueCalled = false
    var willChangeValueSetCalled = false
    var didChangeValueSetCalled = false
    
    
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
}
