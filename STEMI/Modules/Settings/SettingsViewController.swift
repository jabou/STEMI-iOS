//
//  SettingsViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 07/08/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var isInStandbyMode: Bool?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let settingsTableView = childViewControllers.first as! SettingsTableViewController
        settingsTableView.standbyActive = isInStandbyMode
    }

    // MARK: - Handle orientation
    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    // MARK: - Action Handlers
    @IBAction func backButtonActionHandler(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
