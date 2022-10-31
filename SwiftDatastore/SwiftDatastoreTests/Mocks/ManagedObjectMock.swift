//
//  ManagedObjectMock.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 15/07/2022.
//

import Foundation
import CoreData

@testable import SwiftDatastore

@objc(ManagedObjectMock)
class ManagedObjectMock: NSManagedObject {
    var _managedObject = PersistentStoreCoordinatorMock.shared.managedObject
    var _value: Any?
    var _mutableSet = NSMutableSet()
    
    var mutableSetValueCalled = false
    var addObserverCalled = false
    var removeObserverCalled = false
    var setPrimitiveValueCalled = false
    var primitiveValueCalled = false
    
//    convenience init() {
//        self.init(entity: PersistentStoreCoordinatorMock.shared.entityDescription,
//                  insertInto: PersistentStoreCoordinatorMock.shared.mocMock)
//    }
    
    var object: NSManagedObject {
        _managedObject
    }
    
//    override func setPrimitiveValue(_ value: Any?, forKey key: String) {
//        setPrimitiveValueCalled = true
//    }
//    
//    override func primitiveValue(forKey key: String) -> Any? {
//        primitiveValueCalled = true
//        return _value
//    }
    
//    override func mutableSetValue(forKey key: String) -> NSMutableSet {
//        mutableSetValueCalled = true
//        return _mutableSet
//    }
//
//    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions) {
//        addObserverCalled = true
//    }
//
//    override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
//        removeObserverCalled = true
//    }
}
