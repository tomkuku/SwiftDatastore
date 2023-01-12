//
//  AttributeValueType.swift
//  SwiftDatastore
//
//  Created by Tomasz Kukułka on 12/01/2023.
//

import Foundation
import CoreData

public protocol AttributeValueType {
    static var attributeType: NSAttributeType { get }
}

extension Int: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .integer64AttributeType
}

extension Int16: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .integer16AttributeType
}

extension Int32: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .integer32AttributeType
}

extension Int64: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .integer64AttributeType
}

extension Double: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .doubleAttributeType
}

extension Float: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .floatAttributeType
}

extension String: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .stringAttributeType
}

extension Date: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .dateAttributeType
}

extension Data: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .binaryDataAttributeType
}

extension Bool: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .booleanAttributeType
}

extension UUID: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .UUIDAttributeType
}

extension URL: AttributeValueType {
    public private(set) static var attributeType: NSAttributeType = .URIAttributeType
}

