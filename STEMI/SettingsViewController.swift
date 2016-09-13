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
    }

    // MARK: - Handle orientation
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    // MARK: - Action Handlers
    @IBAction func backButtonActionHandler(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
