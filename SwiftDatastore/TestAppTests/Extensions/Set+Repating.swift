//
//  Set+Repating.swift
//  DemoAppTests
//
//  Created by Kukułka Tomasz on 11/10/2022.
//

import Foundation

extension Set {
    init(repating: Int, block: () throws -> Element) throws {
        let array = try (0..<repating).map { _ -> Element in
            try block()
        }
        self = Set(array)
    }
}
