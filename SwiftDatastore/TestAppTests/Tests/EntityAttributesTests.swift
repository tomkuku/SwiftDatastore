//
//  EntityAttributesTests.swift
//  DemoAppTests
//
//  Created by Kukułka Tomasz on 11/10/2022.
//

import XCTest
import SwiftDatastore
import UIKit

@testable import TestApp

class EntityAttributesTests: XCTestCase {
    
    var context: SwiftDatastoreContext!
    
    let testBoolValue = false
    let testDataValue = UIImage(systemName: "pencil")!.pngData()!
    let testDateValue = Date()
    let testDoubleValue: Double = .pi
    let testFloatValue: Float = .pi
    let testIDValue = UUID()
    let testIntValue = 1
    let testStringValue = "apple"
    let testURLValue = URL(string: "https://www.apple.com")!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let datastore = try SwiftDatastore(storingType: .test, storeName: "EntityAttributesTests", datamodelName: "TestModel")
        context = datastore.createNewContext()
    }
    
    override func tearDown() {
        super.tearDown()
        context = nil
    }
    
    func test_optionalAttributes() {
        let expectation = XCTestExpectation(description: "Saving context should end succeeded")
        
        context.perform { context in
            let optionalObject: TestOptionalObject = try context.createObject()
            let notOptionalObject: TestNotOptionalObject = try context.createObject()
            let relationshipObject: TestRelationshipObject = try context.createObject()
            
            let optionalObjects = try Set<TestOptionalObject>(repating: 3) {
                try context.createObject()
            }
            
            self.set_optionalAttributes_nilValues(of: optionalObject)
            self.get_optionalAttributes_nilValues(of: optionalObject)
            
            self.set_relationshipToMany_values(of: relationshipObject,
                                               toOneObject: optionalObject,
                                               toManyObjects: optionalObjects)
            self.get_relationshipToMany_values(of: relationshipObject)
            
            self.set_optionalAttributes_values(of: optionalObject)
            self.get_optionalAttributes_values(of: optionalObject)
            
            self.set_notOptionalAttributes_values(of: notOptionalObject)
            self.get_notOptionalAttributes_values(of: notOptionalObject)
        } success: {
            expectation.fulfill()
        } failure: { error in
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    private func set_optionalAttributes_nilValues(of testObject: TestOptionalObject) {
        testObject.bool = nil
        testObject.data = nil
        testObject.date = nil
        testObject.double = nil
        testObject.float = nil
        testObject.id = nil
        testObject.int = nil
        testObject.string = nil
        testObject.url = nil
    }
    
    private func get_optionalAttributes_nilValues(of testObject: TestOptionalObject) {
        XCTAssertNil(testObject.bool)
        XCTAssertNil(testObject.data)
        XCTAssertNil(testObject.date)
        XCTAssertNil(testObject.double)
        XCTAssertNil(testObject.float)
        XCTAssertNil(testObject.id)
        XCTAssertNil(testObject.int)
        XCTAssertNil(testObject.string)
        XCTAssertNil(testObject.url)
    }
    
    private func set_optionalAttributes_values(of testObject: TestOptionalObject) {
        testObject.bool = testBoolValue
        testObject.data = testDataValue
        testObject.date = testDateValue
        testObject.double = testDoubleValue
        testObject.float = testFloatValue
        testObject.id = testIDValue
        testObject.int = testIntValue
        testObject.string = testStringValue
        testObject.url = testURLValue
    }
    
    private func get_optionalAttributes_values(of testObject: TestOptionalObject) {
        XCTAssertEqual(testObject.bool, testBoolValue)
        XCTAssertEqual(testObject.data, testDataValue)
        XCTAssertEqual(testObject.date, testDateValue)
        XCTAssertEqual(testObject.double, testDoubleValue)
        XCTAssertEqual(testObject.float, testFloatValue)
        XCTAssertEqual(testObject.id, testIDValue)
        XCTAssertEqual(testObject.int, testIntValue)
        XCTAssertEqual(testObject.string, testStringValue)
        XCTAssertEqual(testObject.url, testURLValue)
    }
    
    private func set_notOptionalAttributes_values(of testObject: TestNotOptionalObject) {
        testObject.bool = testBoolValue
        testObject.data = testDataValue
        testObject.date = testDateValue
        testObject.double = testDoubleValue
        testObject.float = testFloatValue
        testObject.id = testIDValue
        testObject.int = testIntValue
        testObject.string = testStringValue
        testObject.url = testURLValue
    }
    
    private func get_notOptionalAttributes_values(of testObject: TestNotOptionalObject) {
        XCTAssertEqual(testObject.bool, testBoolValue)
        XCTAssertEqual(testObject.data, testDataValue)
        XCTAssertEqual(testObject.date, testDateValue)
        XCTAssertEqual(testObject.double, testDoubleValue)
        XCTAssertEqual(testObject.float, testFloatValue)
        XCTAssertEqual(testObject.id, testIDValue)
        XCTAssertEqual(testObject.int, testIntValue)
        XCTAssertEqual(testObject.string, testStringValue)
        XCTAssertEqual(testObject.url, testURLValue)
    }
    
    private func set_relationshipToMany_values(of relationshipObject: TestRelationshipObject,
                                               toOneObject: TestOptionalObject,
                                               toManyObjects: Set<TestOptionalObject>) {
        relationshipObject.toOne = toOneObject
        relationshipObject.toMany = toManyObjects
    }
    
    private func get_relationshipToMany_values(of testObject: TestRelationshipObject) {
        XCTAssertNotNil(testObject.toOne)
        XCTAssertEqual(testObject.toMany.count, 3)
    }
}
