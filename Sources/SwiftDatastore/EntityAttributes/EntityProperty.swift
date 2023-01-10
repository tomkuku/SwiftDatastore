//
//  EntityProperty.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 14/10/2022.
//

import Foundation
import Combine
import CoreData

protocol EntityPropertyLogic: AnyObject {
    var managedObject: ManagedObjectKeyValue! { get set }
    var key: String! { get set }
    var managedObjectObserver: ManagedObjectObserverLogic! { get set }
}

public class EntityProperty<T>: EntityPropertyLogic, ManagedObjectObserverDelegate {
    // Properties which are set after init in DatastoreObject's config method.
    var managedObject: ManagedObjectKeyValue!
    var managedObjectObserver: ManagedObjectObserverLogic!
    
    public var key: String! = ""
    
    var observervingBlocks: [(T) -> Void] = []
    var isObserving = false
    
#if os(iOS)
    let newValuePassthroughSubject = PassthroughSubject<T, Never>()

    public lazy var newValuePublisher: AnyPublisher<T, Never> = {
        addObserverIfNeeded()
        
        return newValuePassthroughSubject.eraseToAnyPublisher()
    }()
#endif
    
    deinit {
        removeObserverIfNeeded()
    }
    
    // MARK: ManagedObjectObserverDelegate
    func observedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
        handleObservedPropertyDidChangeValue(newValue, change: change)
    }
    
    // MARK: Internal
    func getManagedObjectValueForKey<T>() -> T? {
        defer {
            managedObject.didAccessValue(forKey: key)
        }
        managedObject.willAccessValue(forKey: key)
        return managedObject.primitiveValue(forKey: key) as? T
    }
    
    func setManagedObjectValueForKey<T>(value: T?) {
        defer {
            managedObject.didChangeValue(forKey: key)
        }
        managedObject.willChangeValue(forKey: key)
        guard let newValue = value else {
            managedObject.setPrimitiveValue(nil, forKey: key)
            return
        }
        managedObject.setPrimitiveValue(newValue, forKey: key)
        
    }
    
    public func observe(_ block: @escaping (_ newValue: T) -> Void) {
        addObserverIfNeeded()
        
        observervingBlocks.append(block)
    }
    
    func informAboutNewValue(_ newValue: T) {
#if os(iOS)
        newValuePassthroughSubject.send(newValue)
#endif
        
        observervingBlocks.forEach {
            $0(newValue)
        }
    }
    
    func handleObservedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
        // method to override
    }
    
    // MARK: Private
    private func addObserverIfNeeded() {
        guard !isObserving else {
            return
        }
        
        isObserving = true
        
        managedObjectObserver.addObserver(forKey: key, delegate: self)
    }
    
    private func removeObserverIfNeeded() {
        guard !observervingBlocks.isEmpty else {
            return
        }
        
        observervingBlocks.removeAll()
        managedObjectObserver.removeObserver(forKey: key)
    }
}
