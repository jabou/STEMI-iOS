//
//  CalibrationViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import AVFoundation

class CalibrationViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet var legPoints: [UIButton]!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var downArrow: UIButton!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var numberIndicatorLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!

    //MARK: - Private var
    private var _stemi: Hexapod!
    private var _calibrationValues = [Int]()
    private var _changedCalibrationValues = [Int]()
    private var _selectedIndex: Int!
    private var _shouldIncrease = false
    private var _shouldDecrease = false
    private var _movingSound: AVAudioPlayer = AVAudioPlayer()


    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        circleImageView.alpha = 0.0
        numberIndicatorLabel.alpha = 0.0
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let path = NSBundle.mainBundle().pathForResource("moving_sound", ofType: "wav")
        let url = NSURL(fileURLWithPath: path!)
        do {
            _movingSound = try AVAudioPlayer(contentsOfURL: url)
            _movingSound.volume = 0.07
            _movingSound.numberOfLoops = -1
            _movingSound.prepareToPlay()
        } catch let error as NSError {
            #if DEVELOPMENT
                print(error.description)
            #endif
        }


        for leg in legPoints {
            leg.setImage(nil, forState: .Normal)
        }
        upArrow.enabled = false
        downArrow.enabled = false
        hintLabel.hidden = false
        _calibrationValues = []
        _changedCalibrationValues = []
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)


        #if DEBUG
            self._calibrationValues = [56,43,23,36,76,45,76,22,34,76,57,47,37,26,24,13,24]
            self._changedCalibrationValues = self._calibrationValues
        #endif

        _stemi = Hexapod(withCalibrationMode: true)
        _stemi.setIP(UserDefaults.IP())
        _stemi.connectWithCompletion({connected in
            if connected {
                let fetchValues = self._stemi.fetchDataFromHexapod()

                for value in fetchValues {
                    self._calibrationValues.append(Int(value))
                }
                self._changedCalibrationValues = self._calibrationValues
            }
        })
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _stemi.disconnect()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        circleImageView.alpha = 0.0
        numberIndicatorLabel.alpha = 0.0
    }

    //MARK: - Orientation Handling
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeRight
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    //MARK: - UI Buttons change
    private func _setActiveButtonWithId(identifier: Int) {
        for (index, leg) in legPoints.enumerate() {
            numberIndicatorLabel.text = String(_changedCalibrationValues[_selectedIndex])
            if index == identifier {
                leg.setImage(UIImage(named: "calibration_dot"), forState: .Normal)
            } else {
                leg.setImage(nil, forState: .Normal)
            }
        }
    }

    private func _increaseValue() {
        if _changedCalibrationValues[_selectedIndex] < 100 {
            _changedCalibrationValues[_selectedIndex] += 1
            _stemi.increaseValueAtIndex(_selectedIndex)
            numberIndicatorLabel.text = String(_changedCalibrationValues[_selectedIndex])
        } else {
            _stopSound()
        }
    }

    private func _decreaseValue() {
        if _changedCalibrationValues[_selectedIndex] > 0 {
            _changedCalibrationValues[_selectedIndex] -= 1
            _stemi.decreaseValueAtIndex(_selectedIndex)
            numberIndicatorLabel.text = String(_changedCalibrationValues[_selectedIndex])
        } else {
            _stopSound()
        }
    }

    private func _increaseValueOnLongClick() {
        let dataSendQueue: dispatch_queue_t = dispatch_queue_create("Increase Queue", nil)
        dispatch_async(dataSendQueue, {
            while self._shouldIncrease == true {
                NSThread.sleepForTimeInterval(Constants.LongClickSpeed)
                dispatch_async(dispatch_get_main_queue()) {
                    self._increaseValue()
                }
            }
        })
    }

    private func _decreaseValueOnLongClick() {
        let dataSendQueue: dispatch_queue_t = dispatch_queue_create("Decrease Queue", nil)
        dispatch_async(dataSendQueue, {
            while self._shouldDecrease == true {
                NSThread.sleepForTimeInterval(Constants.LongClickSpeed)
                dispatch_async(dispatch_get_main_queue()) {
                    self._decreaseValue()
                }
            }
        })
    }

    private func _discardValuesToInitial(complete: (Bool) -> Void) {

        var calculatingNumbers: [Int] = []

        for i in 0...10 {
            for (j, _) in _calibrationValues.enumerate() {

                if i == 0 {
                    let calc = abs(_calibrationValues[j] - _changedCalibrationValues[j])/10
                    calculatingNumbers.append(calc)
                }

                if i < 10 {
                    if _changedCalibrationValues[j] < _calibrationValues[j] {
                        _changedCalibrationValues[j] += calculatingNumbers[j]
                        do {
                            try _stemi.setValue(UInt8(_changedCalibrationValues[j]), atIndex: j)
                        } catch {
                            #if DEVELOPMENT
                                print("error")
                            #endif
                        }
                    } else if _changedCalibrationValues[j] > _calibrationValues[j] {
                        _changedCalibrationValues[j] -= calculatingNumbers[j]
                        do {
                            try _stemi.setValue(UInt8(_changedCalibrationValues[j]), atIndex: j)
                        } catch {
                            #if DEVELOPMENT
                                print("error")
                            #endif
                        }
                    }
                } else {
                    _changedCalibrationValues[j] = _calibrationValues[j]
                    do {
                        try _stemi.setValue(UInt8(_calibrationValues[j]), atIndex: j)
                    } catch {
                        #if DEVELOPMENT
                            print("error")
                        #endif
                    }
                }
            }
            NSThread.sleepForTimeInterval(0.1)
        }
        complete(true)
    }

    func _stopSound() {
        _movingSound.stop()
        _movingSound.currentTime = 0.0
    }

    //MARK: - Action Handlers
    @IBAction func legsActionHandler(sender: UIButton) {
        upArrow.enabled = true
        downArrow.enabled = true
        hintLabel.hidden = true
        UIView.animateWithDuration(0.2) {
            self.circleImageView.alpha = 1.0
            UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.numberIndicatorLabel.alpha = 1.0
                }, completion: nil)
        }
        _selectedIndex = sender.tag
        _setActiveButtonWithId(_selectedIndex)
    }

    @IBAction func upArrowActionHandler(sender: UIButton) {
        _movingSound.play()
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(_stopSound), userInfo: nil, repeats: false)
        _increaseValue()
    }
    
    @IBAction func downArrowActionHandler(sender: UIButton) {
        _movingSound.play()
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(_stopSound), userInfo: nil, repeats: false)
        _decreaseValue()
    }

    @IBAction func longPressUpButtonActionHandler(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            _stopSound()
            _shouldIncrease = false
        } else if sender.state == .Began {
            _shouldIncrease = true
            _movingSound.play()
            _increaseValueOnLongClick()
        }
    }
    @IBAction func longPressDownButtonActionHandler(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            _stopSound()
            _shouldDecrease = false
        } else if sender.state == .Began {
            _shouldDecrease = true
            _movingSound.play()
            _decreaseValueOnLongClick()
        }
    }
    @IBAction func saveButtonActionHandler(sender: AnyObject) {
        _stemi.writeDataToHexapod { complete in
            if complete {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    @IBAction func cancelButtonActionHandler(sender: AnyObject) {

        let backgroundView = UIView()
        let loadingLabel = UILabel()
        let activityIndicator = UIActivityIndicatorView()

        backgroundView.frame = CGRectMake(0, 0, 130, 130)
        backgroundView.center = view.center
        backgroundView.backgroundColor = UIColor(red: 39/255, green: 38/255, blue: 39/255, alpha: 0.9)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 10
        backgroundView.alpha = 0.0

        loadingLabel.frame = CGRectMake(0, 0, 130, 80)
        loadingLabel.backgroundColor = UIColor.clearColor()
        loadingLabel.textColor = UIColor.whiteColor()
        loadingLabel.adjustsFontSizeToFitWidth = true
        loadingLabel.textAlignment = NSTextAlignment.Center
        loadingLabel.center = CGPointMake(backgroundView.bounds.width/2, backgroundView.bounds.height/2 + 30)
        loadingLabel.text = Localization.localizedString("CANCELING")

        activityIndicator.frame = CGRectMake(0, 0, activityIndicator.bounds.size.width, activityIndicator.bounds.size.height)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = CGPointMake(backgroundView.bounds.width/2, backgroundView.bounds.height/2 - 10)

        backgroundView.addSubview(activityIndicator)
        backgroundView.addSubview(loadingLabel)
        view.addSubview(backgroundView)

        activityIndicator.startAnimating()

        let warningMessage = UIAlertController(title: Localization.localizedString("WARNING"), message: Localization.localizedString("EXIT_CALIBRATION"), preferredStyle: .Alert)
        let yesButton = UIAlertAction(title: Localization.localizedString("YES"), style: .Destructive, handler: {action in

            backgroundView.alpha = 1.0

            dispatch_async(dispatch_get_main_queue(), {
                self._discardValuesToInitial({ complete in
                    if complete {
                        activityIndicator.stopAnimating()
                        backgroundView.removeFromSuperview()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            })
        })
        let noButton = UIAlertAction(title: Localization.localizedString("NO"), style: .Cancel, handler: nil)
        warningMessage.addAction(yesButton)
        warningMessage.addAction(noButton)
        self.presentViewController(warningMessage, animated: true, completion: nil)
    }

}
