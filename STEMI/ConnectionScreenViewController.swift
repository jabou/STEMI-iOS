//
//  ConnectionScreenViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 18/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class ConnectionScreenViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var hintMessageLabel: UILabel!

    //MARK: - Private variables
    private var labelAnimation: NSTimer?

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingIndicator.hidden = true
        button2.hidden = true
        hintMessageLabel.hidden = false
        mainLabel.text = Localization.localizedString("START")
        hintMessageLabel.text = Localization.localizedString("START_TEXT")
        button1.setTitle(Localization.localizedString("CONNECT"), forState: .Normal)
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

        //Clear cache and reset user defaults
        NSURLCache.sharedURLCache().removeAllCachedResponses()

        #if DEVELOPMENT

            UserDefaults.setStemiName("STEMI-06092201");
            UserDefaults.setHardwareVersion("1.0")
            UserDefaults.setWalkingStyle(.TripodGait)
            UserDefaults.setHeight(50)
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.openJoystick), userInfo: nil, repeats: false)
            
        #else
            // Create and make API call to stemi. If file is present and vaild, start using hexapod.
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.timeoutIntervalForRequest = 3

            let session = NSURLSession(configuration: configuration)
            let request = NSURLRequest(URL: NSURL(string: "http://\(UserDefaults.IP())/stemiData.json")!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 3)
            let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in

                //If there is data, try to read it
                if let data = data {
                    //Try to read data from json
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        if let valide = jsonData["isValid"] as? Bool {
                            //JSON is OK - start sending data
                            if valide {
                                if let name = jsonData["stemiID"] as? String, version = jsonData["version"] as? String {
                                    if (UserDefaults.stemiName() == "") || !(UserDefaults.stemiName() == name) {
                                        UserDefaults.setStemiName(name)
                                        UserDefaults.setHardwareVersion(version)
                                        UserDefaults.setWalkingStyle(.TripodGait)
                                        UserDefaults.setHeight(50)
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), { 
                                    NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.openJoystick), userInfo: nil, repeats: false)
                                })
                            } else {
                                dispatch_async(dispatch_get_main_queue(), { 
                                    NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.setupTryAgain), userInfo: nil, repeats: false)
                                })
                            }
                        }
                    }
                        //Error with reading data
                    catch {
                        dispatch_async(dispatch_get_main_queue(), {
                            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.setupTryAgain), userInfo: nil, repeats: false)
                        })
                    }
                }
                    //There is no data on this network -> error
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.setupTryAgain), userInfo: nil, repeats: false)
                    })
                }
            })
            task.resume()
        #endif

    }

    func resetViewState() {
        loadingIndicator.hidden = true
        button2.hidden = true
        hintMessageLabel.hidden = false
        mainLabel.text = Localization.localizedString("START")
        hintMessageLabel.text = Localization.localizedString("START_TEXT")
        button1.setTitle(Localization.localizedString("CONNECT"), forState: .Normal)
        labelAnimation?.invalidate()
        labelAnimation = nil
        button1.userInteractionEnabled = true
    }

    func setupTryAgain() {

        mainLabel.alpha = 1.0
        labelAnimation?.invalidate()
        labelAnimation = nil
        animateLabelShake()

        hintMessageLabel.hidden = false
        mainLabel.text = Localization.localizedString("CONNECTION_FAILED")
        hintMessageLabel.text = Localization.localizedString("FAILED_TEXT")
        button1.setTitle(Localization.localizedString("TRY_AGAIN"), forState: .Normal)
        button1.userInteractionEnabled = true

        button2.hidden = false
        button2.setTitle(Localization.localizedString("CHANGE_IP"), forState: .Normal)
        button2.tag = 2

        loadingIndicator.hidden = true
    }

    func openJoystick() {
        ViewControllers.MainJoystickViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(ViewControllers.MainJoystickViewController, animated: true, completion: {
            complete in
            self.resetViewState()
        })
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
            mainLabel.text = Localization.localizedString("PAIRING")
            button1.setTitle("", forState: .Normal)
            button1.userInteractionEnabled = false
            loadingIndicator.hidden = false
            hintMessageLabel.hidden = true

            button2.hidden = true

            labelAnimation = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(animateLabelAlpha), userInfo: nil, repeats: true)
            labelAnimation?.fire()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: false)
        }
    }

    @IBAction func button2Action(sender: AnyObject) {
        self.presentViewController(ViewControllers.ChangeIPViewController, animated: true, completion: nil)
    }
    
}
