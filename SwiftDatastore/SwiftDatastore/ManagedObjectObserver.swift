//
//  ManagedObjectObserver.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 23/09/2022.
//

import Foundation
import CoreData

protocol ManagedObjectObserverDelegate: AnyObject {
    func observedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?)
}

protocol ManagedObjectObserverLogic {
    func addObserver(forKey key: String, delegate: ManagedObjectObserverDelegate)
    func removeObserver(forKey key: String)
}

final class ManagedObjectObserver: NSObject, ManagedObjectObserverLogic {
    
    private weak var managedObject: ManagedObjectKeyValue?
    private var observers: [String: ManagedObjectObserverDelegate] = [:]
    
    init(managedObject: ManagedObjectKeyValue) {
        self.managedObject = managedObject
    }
    
    func addObserver(forKey key: String, delegate: ManagedObjectObserverDelegate) {
        observers[key] = delegate
        
        managedObject?.addObserver(self, forKeyPath: key, options: [.new], context: nil)
    }
    
    func removeObserver(forKey key: String) {
        observers.removeValue(forKey: key)
        
        managedObject?.removeObserver(self, forKeyPath: key, context: nil)
    }
    
    deinit {
        observers.forEach {
            removeObserver(forKey: $0.0)
        }
    }
    
    // swiftlint:disable:next block_based_kvo
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard
            let change = change,
            change.keys.contains(.newKey),
            let keyPath = keyPath,
            let observer = observers[keyPath]
        else {
            return
        }
        
        let newValue = change[.newKey]
        
        if let changeKindRawValue = change[.kindKey] as? UInt,
           let changeKind = NSKeyValueChange(rawValue: changeKindRawValue) {
            observer.observedPropertyDidChangeValue(newValue, change: changeKind)
        } else {
            observer.observedPropertyDidChangeValue(newValue, change: nil)
        }
    }
}
