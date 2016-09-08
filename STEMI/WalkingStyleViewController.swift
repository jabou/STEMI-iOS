//
//  WalkingStyleViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class WalkingStyleViewController: UIViewController {

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Orientation Handling
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    //MARK: - Action handlers
    @IBAction func doneButtonActionHandler(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
