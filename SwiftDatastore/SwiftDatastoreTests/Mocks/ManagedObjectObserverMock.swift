//
//  ManagedObjectObserverMock.swift
//  SwiftDatastoreTests
//
//  Created by Kukułka Tomasz on 04/10/2022.
//

import Foundation

@testable import SwiftDatastore

final class ManagedObjectObserverMock: ManagedObjectObserverLogic {
    var _removeObserverKey: String?
    var _addObserverForKey: String?
    
    var addObserverNumberOfCalled = 0
    var removeObserverNumberOfCalled = 0
    
    func addObserver(forKey key: String, delegate: ManagedObjectObserverDelegate) {
        _addObserverForKey = key
        addObserverNumberOfCalled += 1
    }
    
    func removeObserver(forKey key: String) {
        _removeObserverKey = key
        removeObserverNumberOfCalled += 1
    }
}
