//
//  ViewController.swift
//  CocoaPodsApp
//
//  Created by Kukułka Tomasz on 24/10/2022.
//

import UIKit
import SwiftDatastore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = try? SwiftDatastore(storeName: "", datamodelName: "")
    }
}
