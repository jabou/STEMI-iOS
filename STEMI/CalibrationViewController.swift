//
//  CalibrationViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class CalibrationViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet var legPoints: [UIButton]!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var downArrow: UIButton!

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        for leg in legPoints {
            leg.setImage(nil, forState: .Normal)
        }
        upArrow.enabled = false
        downArrow.enabled = false
    }

    //MARK: - Orientation Handling
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeRight
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    //MARK: - UI Buttons change
    func setActiveButtonWithId(identifier: Int) {
        for (index, leg) in legPoints.enumerate() {
            if index == identifier {
                leg.setImage(UIImage(named: "calibration_dot"), forState: .Normal)
            } else {
                leg.setImage(nil, forState: .Normal)
            }
        }
    }

    //MARK: - Action Handlers
    @IBAction func legsActionHandler(sender: UIButton) {
        upArrow.enabled = true
        downArrow.enabled = true
        setActiveButtonWithId(sender.tag)
    }

    @IBAction func saveButtonActionHandler(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func cancelButtonActionHandler(sender: AnyObject) {
        let warningMessage = UIAlertController(title: "Warning", message: "Are you sure that you want to exit calibration without saving?", preferredStyle: .Alert)
        let yesButton = UIAlertAction(title: "YES", style: .Default, handler: {action in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        let noButton = UIAlertAction(title: "NO", style: .Cancel, handler: nil)
        warningMessage.addAction(yesButton)
        warningMessage.addAction(noButton)
        self.presentViewController(warningMessage, animated: true, completion: nil)
    }

}
