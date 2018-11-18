//
//  ViewController.swift
//  MeghanHealthKitDemo
//
//  Created by Meghan Mehta on 11/11/18.
//  Copyright © 2018 Meghan Mehta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let healthManager = HealthKitManager()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func authorizeButtonDidTap(_ sender: Any) {
        if healthManager.authorizeHealthKit() {
            healthManager.requestReadWriteAccess()
        }
    }
}

