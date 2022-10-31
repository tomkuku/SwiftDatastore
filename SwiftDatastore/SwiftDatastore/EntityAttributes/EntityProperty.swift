//
//  EntityProperty.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 14/10/2022.
//

import Foundation
import Combine
import CoreData

//class AA: NSManagedObject {
//    override func primitiveValue(forKey key: String) -> Any? {
//        <#code#>
//    }
//
//    override func setPrimitiveValue(_ value: Any?, forKey key: String) {
//        <#code#>
//    }
//
//    override class func mutableSetValue(forKey key: String) -> NSMutableSet {
//        <#code#>
//    }
//
//    override func willAccessValue(forKey key: String?) {
//        <#code#>
//    }
//
//    override func didAccessValue(forKey key: String?) {
//        <#code#>
//    }
//
//    override func willChangeValue(forKey key: String) {
//        <#code#>
//    }
//
//    override func didChangeValue(forKey key: String) {
//        <#code#>
//    }
//
//    override func willChangeValue(forKey inKey: String, withSetMutation inMutationKind: NSKeyValueSetMutationKind, using inObjects: Set<AnyHashable>) {
//        <#code#>
//    }
//
//    override func didChangeValue(forKey inKey: String, withSetMutation inMutationKind: NSKeyValueSetMutationKind, using inObjects: Set<AnyHashable>) {
//        <#code#>
//    }
//}

protocol ManagedObjectKeyValue {
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
}

extension NSManagedObject: ManagedObjectKeyValue {
}

protocol EntityPropertyLogic: AnyObject {
    var managedObject: ManagedObjectKeyValue! { get set }
    var key: String { get set }
    var managedObjectObserver: ManagedObjectObserverLogic! { get set }
}

public class EntityProperty<T>: EntityPropertyLogic, ManagedObjectObserverDelegate {    
    typealias PassthroughSubjectType = PassthroughSubject<T, Never>
    
    var managedObject: ManagedObjectKeyValue!
    var managedObjectObserver: ManagedObjectObserverLogic!
    
    var observervingBlocks: [(T) -> Void] = []
    var newValuePassthroughSubject: PassthroughSubjectType?
    var isObserving = false
    
    public var key: String = ""
    
    public lazy var newValuePublisher: AnyPublisher<T, Never> = {
        let newValueSubject: PassthroughSubjectType
        
        if let subject = newValuePassthroughSubject {
            newValueSubject = subject
        } else {
            let subject = PassthroughSubjectType()
            newValuePassthroughSubject = subject
            newValueSubject = subject
            
            addObserverIfNeeded()
        }
        
        return newValueSubject.eraseToAnyPublisher()
    }()
    
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
        newValuePassthroughSubject?.send(newValue)
        
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
