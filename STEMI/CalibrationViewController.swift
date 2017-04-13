//
//  CalibrationViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import AVFoundation
import STEMIHexapod

class CalibrationViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet var legPoints: [UIButton]!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var downArrow: UIButton!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var numberIndicatorLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!

    //MARK: - Private var
    fileprivate var _stemi: Hexapod!
    fileprivate var _calibrationValues = [Int]()
    fileprivate var _changedCalibrationValues = [Int]()
    fileprivate var _selectedIndex: Int!
    fileprivate var _shouldIncrease = false
    fileprivate var _shouldDecrease = false
    fileprivate var _movingSound: AVAudioPlayer = AVAudioPlayer()


    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        circleImageView.alpha = 0.0
        numberIndicatorLabel.alpha = 0.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let path = Bundle.main.path(forResource: "moving_sound", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        do {
            _movingSound = try AVAudioPlayer(contentsOf: url)
            _movingSound.volume = 0.07
            _movingSound.numberOfLoops = -1
            _movingSound.prepareToPlay()
        } catch let error as NSError {
            #if DEBUG
                print(error.description)
            #endif
        }


        for leg in legPoints {
            leg.setImage(nil, for: UIControlState())
        }
        upArrow.isEnabled = false
        downArrow.isEnabled = false
        hintLabel.isHidden = false
        _calibrationValues = []
        _changedCalibrationValues = []
    }

    override func viewDidAppear(_ animated: Bool) {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _stemi.disconnect()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        circleImageView.alpha = 0.0
        numberIndicatorLabel.alpha = 0.0
    }

    //MARK: - Orientation Handling
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }

    override var shouldAutorotate : Bool {
        return false
    }

    //MARK: - UI Buttons change
    fileprivate func _setActiveButtonWithId(_ identifier: Int) {
        for (index, leg) in legPoints.enumerated() {
            numberIndicatorLabel.text = String(_changedCalibrationValues[_selectedIndex])
            if index == identifier {
                leg.setImage(UIImage(named: "calibration_dot"), for: UIControlState())
            } else {
                leg.setImage(nil, for: UIControlState())
            }
        }
    }

    fileprivate func _increaseValue() {
        if _changedCalibrationValues[_selectedIndex] < 100 {
            _changedCalibrationValues[_selectedIndex] += 1
            _stemi.increaseCalibrationValueAtIndex(_selectedIndex)
            numberIndicatorLabel.text = String(_changedCalibrationValues[_selectedIndex])
        } else {
            _stopSound()
        }
    }

    fileprivate func _decreaseValue() {
        if _changedCalibrationValues[_selectedIndex] > 0 {
            _changedCalibrationValues[_selectedIndex] -= 1
            _stemi.decreaseCalibrationValueAtIndex(_selectedIndex)
            numberIndicatorLabel.text = String(_changedCalibrationValues[_selectedIndex])
        } else {
            _stopSound()
        }
    }

    fileprivate func _increaseValueOnLongClick() {
        let dataSendQueue: DispatchQueue = DispatchQueue(label: "Increase Queue", attributes: [])
        dataSendQueue.async(execute: {
            while self._shouldIncrease == true {
                Thread.sleep(forTimeInterval: Constants.LongClickSpeed)
                DispatchQueue.main.async {
                    self._increaseValue()
                }
            }
        })
    }

    fileprivate func _decreaseValueOnLongClick() {
        let dataSendQueue: DispatchQueue = DispatchQueue(label: "Decrease Queue", attributes: [])
        dataSendQueue.async(execute: {
            while self._shouldDecrease == true {
                Thread.sleep(forTimeInterval: Constants.LongClickSpeed)
                DispatchQueue.main.async {
                    self._decreaseValue()
                }
            }
        })
    }

    fileprivate func _discardValuesToInitial(_ complete: (Bool) -> Void) {

        var calculatingNumbers: [Int] = []

        for i in 0...10 {
            for (j, _) in _calibrationValues.enumerated() {

                if i == 0 {
                    let calc = abs(_calibrationValues[j] - _changedCalibrationValues[j])/10
                    calculatingNumbers.append(calc)
                }

                if i < 10 {
                    if _changedCalibrationValues[j] < _calibrationValues[j] {
                        _changedCalibrationValues[j] += calculatingNumbers[j]
                        do {
                            try _stemi.setCalibrationValue(UInt8(_changedCalibrationValues[j]), atIndex: j)
                        } catch {
                            #if DEBUG
                                print("error")
                            #endif
                        }
                    } else if _changedCalibrationValues[j] > _calibrationValues[j] {
                        _changedCalibrationValues[j] -= calculatingNumbers[j]
                        do {
                            try _stemi.setCalibrationValue(UInt8(_changedCalibrationValues[j]), atIndex: j)
                        } catch {
                            #if DEBUG
                                print("error")
                            #endif
                        }
                    }
                } else {
                    _changedCalibrationValues[j] = _calibrationValues[j]
                    do {
                        try _stemi.setCalibrationValue(UInt8(_calibrationValues[j]), atIndex: j)
                    } catch {
                        #if DEBUG
                            print("error")
                        #endif
                    }
                }
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        complete(true)
    }

    func _stopSound() {
        _movingSound.stop()
        _movingSound.currentTime = 0.0
    }

    //MARK: - Action Handlers
    @IBAction func legsActionHandler(_ sender: UIButton) {
        upArrow.isEnabled = true
        downArrow.isEnabled = true
        hintLabel.isHidden = true
        UIView.animate(withDuration: 0.2, animations: {
            self.circleImageView.alpha = 1.0
            UIView.animate(withDuration: 0.2, delay: 0.1, options: UIViewAnimationOptions(), animations: {
                self.numberIndicatorLabel.alpha = 1.0
                }, completion: nil)
        }) 
        _selectedIndex = sender.tag
        _setActiveButtonWithId(_selectedIndex)
    }

    @IBAction func upArrowActionHandler(_ sender: UIButton) {
        _movingSound.play()
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(_stopSound), userInfo: nil, repeats: false)
        _increaseValue()
    }
    
    @IBAction func downArrowActionHandler(_ sender: UIButton) {
        _movingSound.play()
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(_stopSound), userInfo: nil, repeats: false)
        _decreaseValue()
    }

    @IBAction func longPressUpButtonActionHandler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            _stopSound()
            _shouldIncrease = false
        } else if sender.state == .began {
            _shouldIncrease = true
            _movingSound.play()
            _increaseValueOnLongClick()
        }
    }
    @IBAction func longPressDownButtonActionHandler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            _stopSound()
            _shouldDecrease = false
        } else if sender.state == .began {
            _shouldDecrease = true
            _movingSound.play()
            _decreaseValueOnLongClick()
        }
    }
    @IBAction func saveButtonActionHandler(_ sender: AnyObject) {
        _stemi.writeDataToHexapod { complete in
            if complete {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func cancelButtonActionHandler(_ sender: AnyObject) {

        let backgroundView = UIView()
        let loadingLabel = UILabel()
        let activityIndicator = UIActivityIndicatorView()

        backgroundView.frame = CGRect(x: 0, y: 0, width: 130, height: 130)
        backgroundView.center = view.center
        backgroundView.backgroundColor = UIColor(red: 39/255, green: 38/255, blue: 39/255, alpha: 0.9)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 10
        backgroundView.alpha = 0.0

        loadingLabel.frame = CGRect(x: 0, y: 0, width: 130, height: 80)
        loadingLabel.backgroundColor = UIColor.clear
        loadingLabel.textColor = UIColor.white
        loadingLabel.adjustsFontSizeToFitWidth = true
        loadingLabel.textAlignment = NSTextAlignment.center
        loadingLabel.center = CGPoint(x: backgroundView.bounds.width/2, y: backgroundView.bounds.height/2 + 30)
        loadingLabel.text = Localization.localizedString("CANCELING")

        activityIndicator.frame = CGRect(x: 0, y: 0, width: activityIndicator.bounds.size.width, height: activityIndicator.bounds.size.height)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: backgroundView.bounds.width/2, y: backgroundView.bounds.height/2 - 10)

        backgroundView.addSubview(activityIndicator)
        backgroundView.addSubview(loadingLabel)
        view.addSubview(backgroundView)

        activityIndicator.startAnimating()

        let warningMessage = UIAlertController(title: Localization.localizedString("WARNING"), message: Localization.localizedString("EXIT_CALIBRATION"), preferredStyle: .alert)
        let yesButton = UIAlertAction(title: Localization.localizedString("YES"), style: .destructive, handler: {action in

            backgroundView.alpha = 1.0

            DispatchQueue.main.async(execute: {
                self._discardValuesToInitial({ complete in
                    if complete {
                        activityIndicator.stopAnimating()
                        backgroundView.removeFromSuperview()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            })
        })
        let noButton = UIAlertAction(title: Localization.localizedString("NO"), style: .cancel, handler: nil)
        warningMessage.addAction(yesButton)
        warningMessage.addAction(noButton)
        self.present(warningMessage, animated: true, completion: nil)
    }

}
