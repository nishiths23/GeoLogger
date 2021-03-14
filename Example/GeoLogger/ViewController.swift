//
//  ViewController.swift
//  GeoLogger
//
//  Created by nishiths23 on 03/14/2021.
//  Copyright (c) 2021 nishiths23. All rights reserved.
//

import UIKit
import GeoLoggerSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        GeoLogger.requestPermission(true, requestTemporaryFullAccuracy: true) { (permissionsNotGranted, locationServicesDisabled) in
            // Show alert
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func logButtonPressed(_ sender: UIButton) {
        GeoLogger.log(api: "<API url>") { (success, retryCount) in
            //Handle any errors
        }
    }
}

