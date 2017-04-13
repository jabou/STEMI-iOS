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
    fileprivate var labelAnimation: Timer?
    fileprivate var _shouldSpin: Bool = false


    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        mainLabel.isHidden = false
        button2.isHidden = true
        hintMessageLabel.isHidden = false
        loadingView.isHidden = true
        mainLabel.text = Localization.localizedString("START")
        hintMessageLabel.text = Localization.localizedString("START_TEXT")
        button1.setBackgroundImage(UIImage(named: "buttonBorder"), for: UIControlState())
        button1.setTitle(Localization.localizedString("CONNECT"), for: UIControlState())
        button1.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 15)
        button1.setTitleColor(UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0), for: UIControlState())
        button1.tag = 1
    }

    //MARK: - Rotation handling
    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    //MARK: - Connection view state handlers
    func checkConnection() {

        //Clear cache and reset user defaults
        URLCache.shared.removeAllCachedResponses()
        
        // Create and make API call to stemi. If file is present and vaild, start using hexapod.
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
        
        let session = URLSession(configuration: configuration)
        let request = URLRequest(url: URL(string: "http://\(UserDefaults.IP())/stemiData.json")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 3)
        let task: URLSessionTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            //If there is data, try to read it
            if let data = data {
                //Try to read data from json
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let valide = jsonData["isValid"] as? Bool {
                            //JSON is OK - start sending data
                            if valide {
                                if let name = jsonData["stemiID"] as? String, let version = jsonData["version"] as? String {
                                    if (UserDefaults.stemiName() == "") || !(UserDefaults.stemiName() == name) {
                                        UserDefaults.setStemiName(name)
                                        UserDefaults.setHardwareVersion(version)
                                        UserDefaults.setWalkingStyle(.tripodGait)
                                        UserDefaults.setHeight(50)
                                    }
                                }
                                DispatchQueue.main.async(execute: {
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.openJoystick), userInfo: nil, repeats: false)
                                })
                            } else {
                                DispatchQueue.main.async(execute: {
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.setupTryAgain), userInfo: nil, repeats: false)
                                })
                            }
                        }
                    }
                }
                    //Error with reading data
                catch {
                    DispatchQueue.main.async(execute: {
                        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.setupTryAgain), userInfo: nil, repeats: false)
                    })
                }
            }
                //There is no data on this network -> error
            else {
                DispatchQueue.main.async(execute: {
                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.setupTryAgain), userInfo: nil, repeats: false)
                })
            }
        })
        task.resume()

    }

    func resetViewState() {

        if _shouldSpin {
            _stopSpin()
        }

        button2.isHidden = true
        hintMessageLabel.isHidden = false
        loadingView.isHidden = true
        mainLabel.isHidden = false
        mainLabel.text = Localization.localizedString("START")
        hintMessageLabel.text = Localization.localizedString("START_TEXT")
        button1.setBackgroundImage(UIImage(named: "buttonBorder"), for: UIControlState())
        button1.setTitle(Localization.localizedString("CONNECT"), for: UIControlState())
        button1.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 15)
        button1.setTitleColor(UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0), for: UIControlState())
        labelAnimation?.invalidate()
        labelAnimation = nil
        button1.isUserInteractionEnabled = true
    }

    func setupTryAgain() {

        if _shouldSpin {
            _stopSpin()
        }

        mainLabel.isHidden = false
        mainLabel.alpha = 1.0
        labelAnimation?.invalidate()
        labelAnimation = nil
        animateLabelShake()

        hintMessageLabel.isHidden = false
        loadingView.isHidden = true
        mainLabel.text = Localization.localizedString("CONNECTION_FAILED")
        hintMessageLabel.text = Localization.localizedString("FAILED_TEXT")
        button1.setBackgroundImage(UIImage(named: "buttonBorder"), for: UIControlState())
        button1.setTitle(Localization.localizedString("TRY_AGAIN"), for: UIControlState())
        button1.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 15)
        button1.setTitleColor(UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0), for: UIControlState())
        button1.isUserInteractionEnabled = true

        button2.isHidden = false
        button2.setTitle(Localization.localizedString("CHANGE_IP"), for: UIControlState())
        button2.tag = 2

    }

    func openJoystick() {
        ViewControllers.MainJoystickViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(ViewControllers.MainJoystickViewController, animated: true, completion: {
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

        UIView.animate(withDuration: 0.05, animations: {
            self.mainLabel.frame = CGRect(x: labelX - 4, y: labelY, width: labelWidth, height: labelHeight)
            self.mainLabel.layoutIfNeeded()
            }, completion: { complete in
                UIView.animate(withDuration: 0.05, animations: {
                    self.mainLabel.frame = CGRect(x: labelX + 4, y: labelY, width: labelWidth, height: labelHeight)
                    self.mainLabel.layoutIfNeeded()
                    }, completion: { complete in
                        UIView.animate(withDuration: 0.05, animations: {
                            self.mainLabel.frame = CGRect(x: labelX - 4, y: labelY, width: labelWidth, height: labelHeight)
                            self.mainLabel.layoutIfNeeded()
                            }, completion: { complete in
                                self.mainLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
                                self.mainLabel.layoutIfNeeded()
                        })
                })
        })
    }

    //MARK: - Loadingspinning private helpers
    fileprivate func _spin() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.spinningImageView.transform = self.spinningImageView.transform.rotated(by: CGFloat(M_PI/2))
            }, completion: { complete in
                if self._shouldSpin == true {
                    self._spin()
                }
        })
    }

    func animateLogoAlpha() {
        UIView.animate(withDuration: 0.7, animations: {
            self.hexapodLogoImageView.alpha = 0.3
            }, completion: { complete in
                UIView.animate(withDuration: 0.7, animations: {
                    self.hexapodLogoImageView.alpha = 1.0
                })
        })
    }


    fileprivate func _startSpin() {
        if !_shouldSpin {
            self._shouldSpin = true
            self._spin()
        }
    }

    fileprivate func _stopSpin() {
        _shouldSpin = false
    }

    //MARK: - Action handlers
    @IBAction func button1Action(_ sender: AnyObject) {

        if button1.tag == 1 {
            loadingView.isHidden = false
            mainLabel.isHidden = true
            _startSpin()
            button1.setTitle(Localization.localizedString("PAIRING"), for: UIControlState())
            button1.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 20)
            button1.setTitleColor(UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6), for: UIControlState())
            button1.setBackgroundImage(nil, for: UIControlState())
            button1.isUserInteractionEnabled = false
            hintMessageLabel.isHidden = true

            button2.isHidden = true

            labelAnimation = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(animateLogoAlpha), userInfo: nil, repeats: true)
            labelAnimation?.fire()
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: false)
        }
    }

    @IBAction func button2Action(_ sender: AnyObject) {
        self.present(ViewControllers.ChangeIPViewController, animated: true, completion: nil)
    }
    
}
