//
//  EntityAttributesTests.swift
//  DemoAppCocoaPodsTests
//
//  Created by Kukułka Tomasz on 11/10/2022.
//

import XCTest
import SwiftDatastore
import Hamcrest
import UIKit

@testable import DemoAppCocoaPods

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
        assertThat(testObject.bool, nilValue())
        assertThat(testObject.data, nilValue())
        assertThat(testObject.date, nilValue())
        assertThat(testObject.double, nilValue())
        assertThat(testObject.float, nilValue())
        assertThat(testObject.id, nilValue())
        assertThat(testObject.int, nilValue())
        assertThat(testObject.string, nilValue())
        assertThat(testObject.url, nilValue())
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
        assertThat(testObject.bool, equalTo(testBoolValue))
        assertThat(testObject.data, equalTo(testDataValue))
        assertThat(testObject.date, equalTo(testDateValue))
        assertThat(testObject.double, equalTo(testDoubleValue))
        assertThat(testObject.float, equalTo(testFloatValue))
        assertThat(testObject.id, equalTo(testIDValue))
        assertThat(testObject.int, equalTo(testIntValue))
        assertThat(testObject.string, equalTo(testStringValue))
        assertThat(testObject.url, equalTo(testURLValue))
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
        assertThat(testObject.bool, equalTo(testBoolValue))
        assertThat(testObject.data, equalTo(testDataValue))
        assertThat(testObject.date, equalTo(testDateValue))
        assertThat(testObject.double, equalTo(testDoubleValue))
        assertThat(testObject.float, equalTo(testFloatValue))
        assertThat(testObject.id, equalTo(testIDValue))
        assertThat(testObject.int, equalTo(testIntValue))
        assertThat(testObject.string, equalTo(testStringValue))
        assertThat(testObject.url, equalTo(testURLValue))
    }
    
    private func set_relationshipToMany_values(of relationshipObject: TestRelationshipObject,
                                               toOneObject: TestOptionalObject,
                                               toManyObjects: Set<TestOptionalObject>) {
        relationshipObject.toOne = toOneObject
        relationshipObject.toMany = toManyObjects
    }
    
    private func get_relationshipToMany_values(of testObject: TestRelationshipObject) {
        assertThat(testObject.toOne, not(nil))
        assertThat(testObject.toMany.count, equalTo(3))
    }
}
