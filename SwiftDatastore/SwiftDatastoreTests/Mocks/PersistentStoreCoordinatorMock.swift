//
//  Mock.swift
//  DatastoreTests
//
//  Created by Kukułka Tomasz on 03/08/2022.
//

import Foundation
import CoreData

final class PersistentStoreCoordinatorMock {
    
    var managedObject: NSManagedObject {
        return NSManagedObject(entity: entityDescription,
                               insertInto: mocMock)
    }
    
    lazy var mocMock: ManagedObjectContextMock = {
        let context = ManagedObjectContextMock()
        context.persistentStoreCoordinator = persistentStore
        return context
    }()
    
    let entityDescription: NSEntityDescription = {
        let namAttribute = NSAttributeDescription()
        namAttribute.name = "name"
        namAttribute.attributeType = .stringAttributeType
        namAttribute.isOptional = true
        
        let entityDescription = NSEntityDescription()
        entityDescription.name = "TestObject"
        entityDescription.properties = [namAttribute]
        
        return entityDescription
    }()
    
    lazy var persistentStore: NSPersistentStoreCoordinator = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        managedObjectModel?.entities = [entityDescription]
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        try! psc.addPersistentStore(ofType: NSInMemoryStoreType,
                                    configurationName: nil,
                                    at: nil,
                                    options: nil)
        return psc
    }()
    
    static let shared = PersistentStoreCoordinatorMock()
    
    private init() { }
}
