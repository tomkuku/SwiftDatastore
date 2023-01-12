//
//  SwiftDatastoreModel.swift
//  SwiftDatastore
//
//  Created by Tomasz Kukułka on 09/01/2023.
//

import Foundation
import CoreData

protocol SwiftDatastoreModelLogic {
    var managedObjectModel: NSManagedObjectModel { get }
}

public final class SwiftDatastoreModel {
    let entities: [NSEntityDescription]
    
    var managedObjectModel: NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = entities
        return model
    }
    
    public init(from objectTypes: DatastoreObject.Type...) {
        let entityDescription = NSEntityDescription(name: "-")
        let managedObject = NSManagedObject(entity: entityDescription, insertInto: nil)
        
        entities = objectTypes.map {
            let object = $0.init(managedObject: managedObject)
            return object.createEntityDescription()
        }
        
        handleRelationships()
    }
    
    private func handleRelationships() {
        entities.forEach { entity in
            entity.relationshipsByName.forEach { (_, relationship) in
                guard let inverseRelationship = relationship as? InverseRelationshipDescription else {
                    return
                }
                
                let destinationRelationship = findRelationship(forEntityName: inverseRelationship.invsereObjectName,
                                                               propertyName: inverseRelationship.inversePropertyName)
                
                inverseRelationship.inverseRelationship = destinationRelationship
                inverseRelationship.destinationEntity = destinationRelationship.entity
                
                destinationRelationship.inverseRelationship = inverseRelationship
                destinationRelationship.destinationEntity = entity
            }
        }
    }
    
    private func findRelationship(forEntityName entityName: String, propertyName: String) -> NSRelationshipDescription {
        guard let entity = entities.first(where: { $0.name == entityName }) else {
            Logger.log.fatal("No entity for name: \(entityName)")
        }
        
        guard let relationship = entity.relationshipsByName.first(where: { $0.key == propertyName }) else {
            Logger.log.fatal("No relationship for name: \(propertyName)")
        }
        
        return relationship.value
    }
}