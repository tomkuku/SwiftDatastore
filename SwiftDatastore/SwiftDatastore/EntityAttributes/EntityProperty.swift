//
//  EntityProperty.swift
//  SwiftDatastore
//
//  Created by Kukułka Tomasz on 14/10/2022.
//

import Foundation
import Combine

protocol EntityPropertyLogic: AnyObject {
    var managedObjectWrapper: ManagedObjectWrapperLogic! { get set }
    var key: String { get set }
    var managedObjectObserver: ManagedObjectObserverLogic! { get set }
}

public class EntityProperty<T>: EntityPropertyLogic, ManagedObjectObserverDelegate {    
    typealias PassthroughSubjectType = PassthroughSubject<T, Never>
        
    var managedObjectWrapper: ManagedObjectWrapperLogic!
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
    
    // MARK: ManagedObjectObserverDelegate
    func observedPropertyDidChangeValue(_ newValue: Any?, change: NSKeyValueChange?) {
        handleObservedPropertyDidChangeValue(newValue, change: change)
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
