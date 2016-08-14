//
//  SettingsViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 07/08/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
    }

    // MARK: - Orientation Handling

    override func shouldAutorotate() -> Bool {
        return false
    }

    // MARK: - Action Handlers

    @IBAction func backButtonActionHandler(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
