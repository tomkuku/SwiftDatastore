//
//  ViewController.swift
//  SPMApp
//
//  Created by Kukułka Tomasz on 11/11/2022.
//

import UIKit
import SwiftDatastore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = try? SwiftDatastore(storeName: "", datamodelName: "")
    }
}
