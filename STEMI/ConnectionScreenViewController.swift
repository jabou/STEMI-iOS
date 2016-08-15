//
//  ConnectionScreenViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 18/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import STEMIHexapod
import Alamofire

class ConnectionScreenViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    //MARK: - Private variables
    private var labelAnimation: NSTimer?
    private var alamofireManager = Alamofire.Manager.sharedInstance

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingIndicator.hidden = true
        button2.hidden = true
        mainLabel.text = "WELCOME"
        button1.setTitle("CONNECT", forState: .Normal)
        button1.tag = 1
    }

    //MARK: - Rotation handling
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    //MARK: - Connection view state handlers
    func checkConnection() {
        //Clear cache
        NSURLCache.sharedURLCache().removeAllCachedResponses()

        // Create and make API call to stemi. If file is present and vaild, start using hexapod.
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 3
        alamofireManager = Alamofire.Manager(configuration: configuration)
        alamofireManager.request(.GET, "http://\(UserDefaults.IP())/stemiData.json").responseJSON { response in
            print(response)
            guard response.result.isSuccess else {
                NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.setupTryAgain), userInfo: nil, repeats: false)
                return
            }
            guard let responseJSON = response.result.value as? [String:AnyObject] else {
                NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.setupTryAgain), userInfo: nil, repeats: false)
                return
            }
            if let valide = responseJSON["isValid"] as? Bool {
                if valide {
                    NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.openJoystick), userInfo: nil, repeats: false)
                }
            }
        }


    }

    func setupTryAgain() {

        mainLabel.alpha = 1.0
        labelAnimation?.invalidate()
        labelAnimation = nil
        animateLabelShake()

        mainLabel.text = "FAILED TO CONNECT"
        button1.setTitle("TRY AGAIN", forState: .Normal)
        button1.userInteractionEnabled = true

        button2.hidden = false
        button2.setTitle("CHANGE IP", forState: .Normal)
        button2.tag = 2

        loadingIndicator.hidden = true
    }

    func openJoystick() {
        performSegueWithIdentifier("connectionSuccess", sender: nil)
    }

    //MARK: - Label animations
    func animateLabelAlpha() {
        UIView.animateWithDuration(0.7, animations: {
            self.mainLabel.alpha = 0.5
            }, completion: { complete in
                UIView.animateWithDuration(0.7, animations: {
                    self.mainLabel.alpha = 1.0
                })
        })
    }

    func animateLabelShake() {
        let labelFrame = mainLabel.frame
        let labelWidth = labelFrame.size.width
        let labelHeight = labelFrame.size.height
        let labelX = labelFrame.origin.x
        let labelY = labelFrame.origin.y

        UIView.animateWithDuration(0.05, animations: {
            self.mainLabel.frame = CGRectMake(labelX - 4, labelY, labelWidth, labelHeight)
            self.mainLabel.layoutIfNeeded()
            }, completion: { complete in
                UIView.animateWithDuration(0.05, animations: {
                    self.mainLabel.frame = CGRectMake(labelX + 4, labelY, labelWidth, labelHeight)
                    self.mainLabel.layoutIfNeeded()
                    }, completion: { complete in
                        UIView.animateWithDuration(0.05, animations: {
                            self.mainLabel.frame = CGRectMake(labelX - 4, labelY, labelWidth, labelHeight)
                            self.mainLabel.layoutIfNeeded()
                            }, completion: { complete in
                                self.mainLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight)
                                self.mainLabel.layoutIfNeeded()
                        })
                })
        })
    }

    //MARK: - Action handlers
    @IBAction func button1Action(sender: AnyObject) {

        if button1.tag == 1 {
            mainLabel.text = "STEMI IS NOW CONNECTING"
            button1.setTitle("", forState: .Normal)
            button1.userInteractionEnabled = false
            loadingIndicator.hidden = false

            button2.hidden = true

            labelAnimation = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(animateLabelAlpha), userInfo: nil, repeats: true)
            labelAnimation?.fire()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: false)
        }
    }

    @IBAction func button2Action(sender: AnyObject) {
        performSegueWithIdentifier("enterIP", sender: nil)
    }


    // TODO: REMOVE THIS ON FINAL VERSION. THIS IS TMP HACK TO ENTER (DISMISS VIEW) INTO APP WITHOUT CONNECTION TO STEMI
    @IBAction func connectionButton(sender: AnyObject) {
        performSegueWithIdentifier("connectionSuccess", sender: nil)
    }

}
