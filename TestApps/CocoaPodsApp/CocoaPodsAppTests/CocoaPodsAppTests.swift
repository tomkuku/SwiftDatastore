//
//  CocoaPodsAppTests.swift
//  CocoaPodsAppTests
//
//  Created by Kukułka Tomasz on 24/10/2022.
//

import XCTest
import SwiftDatastore

@testable import CocoaPodsApp

final class CocoaPodsAppTests: XCTestCase {

    func test_createAndFetch() throws {
        // given
        let datastore = try SwiftDatastore(storingType: .test, storeName: "cocoa-pods-app-tests", datamodelName: "CocoaPodsAppModel")
        
        let context = datastore.createNewContext()
        
        let saveExpectation = XCTestExpectation()
        let fetchExpectation = XCTestExpectation()
        
        var fetchPerson: Person?
        
        // when
        context.perform { context in
            let person: Person = try context.createObject()
            person.name = "Tomek"
            try context.saveChanges()
        } success: {
            saveExpectation.fulfill()
        } failure: { error in
            XCTFail(error.localizedDescription)
        }
        
        // then
        wait(for: [saveExpectation], timeout: 2)
        
        // when
        context.perform { context in
            fetchPerson = try context.fetchFirst(orderBy: [.asc(\.$name)])
        } success: {
            fetchExpectation.fulfill()
        } failure: { error in
            XCTFail(error.localizedDescription)
        }
        
        // then
        wait(for: [fetchExpectation], timeout: 2)
        XCTAssertEqual(fetchPerson?.name, "Tomek")
    }
}
