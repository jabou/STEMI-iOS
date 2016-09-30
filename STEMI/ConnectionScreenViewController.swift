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
    @IBOutlet weak var hintMessageLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var hexapodLogoImageView: UIImageView!
    @IBOutlet weak var spinningImageView: UIImageView!

    //MARK: - Private variables
    private var labelAnimation: NSTimer?
    private var _shouldSpin: Bool = false


    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        mainLabel.hidden = false
        button2.hidden = true
        hintMessageLabel.hidden = false
        loadingView.hidden = true
        mainLabel.text = Localization.localizedString("START")
        hintMessageLabel.text = Localization.localizedString("START_TEXT")
        button1.setBackgroundImage(UIImage(named: "buttonBorder"), forState: .Normal)
        button1.setTitle(Localization.localizedString("CONNECT"), forState: .Normal)
        button1.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 15)
        button1.setTitleColor(UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0), forState: .Normal)
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

        if _shouldSpin {
            _stopSpin()
        }

        button2.hidden = true
        hintMessageLabel.hidden = false
        loadingView.hidden = true
        mainLabel.hidden = false
        mainLabel.text = Localization.localizedString("START")
        hintMessageLabel.text = Localization.localizedString("START_TEXT")
        button1.setBackgroundImage(UIImage(named: "buttonBorder"), forState: .Normal)
        button1.setTitle(Localization.localizedString("CONNECT"), forState: .Normal)
        button1.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 15)
        button1.setTitleColor(UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0), forState: .Normal)
        labelAnimation?.invalidate()
        labelAnimation = nil
        button1.userInteractionEnabled = true
    }

    func setupTryAgain() {

        if _shouldSpin {
            _stopSpin()
        }

        mainLabel.hidden = false
        mainLabel.alpha = 1.0
        labelAnimation?.invalidate()
        labelAnimation = nil
        animateLabelShake()

        hintMessageLabel.hidden = false
        loadingView.hidden = true
        mainLabel.text = Localization.localizedString("CONNECTION_FAILED")
        hintMessageLabel.text = Localization.localizedString("FAILED_TEXT")
        button1.setBackgroundImage(UIImage(named: "buttonBorder"), forState: .Normal)
        button1.setTitle(Localization.localizedString("TRY_AGAIN"), forState: .Normal)
        button1.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 15)
        button1.setTitleColor(UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0), forState: .Normal)
        button1.userInteractionEnabled = true

        button2.hidden = false
        button2.setTitle(Localization.localizedString("CHANGE_IP"), forState: .Normal)
        button2.tag = 2

    }

    func openJoystick() {
        ViewControllers.MainJoystickViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(ViewControllers.MainJoystickViewController, animated: true, completion: {
            complete in
            self.resetViewState()
        })
    }

    //MARK: - Label animations

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

    //MARK: - Loadingspinning private helpers
    private func _spin() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.spinningImageView.transform = CGAffineTransformRotate(self.spinningImageView.transform, CGFloat(M_PI/2))
            }, completion: { complete in
                if self._shouldSpin == true {
                    self._spin()
                }
        })
    }

    func animateLogoAlpha() {
        UIView.animateWithDuration(0.7, animations: {
            self.hexapodLogoImageView.alpha = 0.3
            }, completion: { complete in
                UIView.animateWithDuration(0.7, animations: {
                    self.hexapodLogoImageView.alpha = 1.0
                })
        })
    }


    private func _startSpin() {
        if !_shouldSpin {
            self._shouldSpin = true
            self._spin()
        }
    }

    private func _stopSpin() {
        _shouldSpin = false
    }

    //MARK: - Action handlers
    @IBAction func button1Action(sender: AnyObject) {

        if button1.tag == 1 {
            loadingView.hidden = false
            mainLabel.hidden = true
            _startSpin()
            button1.setTitle(Localization.localizedString("PAIRING"), forState: .Normal)
            button1.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 20)
            button1.setTitleColor(UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6), forState: .Normal)
            button1.setBackgroundImage(nil, forState: .Normal)
            button1.userInteractionEnabled = false
            hintMessageLabel.hidden = true

            button2.hidden = true

            labelAnimation = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(animateLogoAlpha), userInfo: nil, repeats: true)
            labelAnimation?.fire()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: false)
        }
    }

    @IBAction func button2Action(sender: AnyObject) {
        self.presentViewController(ViewControllers.ChangeIPViewController, animated: true, completion: nil)
    }
    
}
