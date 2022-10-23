//
//  IndexPath+string.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 12/08/2022.
//

import Foundation
import UIKit

extension IndexPath {
    var string: String {
        "IndexPath(row: \(self.row), section: \(self.section))"
    }
}
