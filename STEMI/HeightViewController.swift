//
//  HeightViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import AVFoundation
import STEMIHexapod

class HeightViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var heightIndicator: UILabel!

    //MARK: - Private variables
    fileprivate var _stemi: Hexapod!
    fileprivate var _currentHeight: Int = 0
    fileprivate var _shouldIncrease = false
    fileprivate var _shouldDecrease = false
    fileprivate var _movingSound: AVAudioPlayer = AVAudioPlayer()

    var counter = 0

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        _currentHeight = Int(UserDefaults.height())
        heightIndicator.text = String(_currentHeight)

        let path = Bundle.main.path(forResource: "moving_sound", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        do {
            _movingSound = try AVAudioPlayer(contentsOf: url)
            _movingSound.volume = 0.07
            _movingSound.prepareToPlay()
        } catch let error as NSError {
            #if DEBUG
                print(error.description)
            #endif
        }

        _stemi = Hexapod()
        _stemi.setIP(UserDefaults.IP())
        _stemi.setHeight(UserDefaults.height())
        _stemi.connect()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _stemi.disconnect()
    }

    // MARK: - Orientation Handling
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var shouldAutorotate : Bool {
        return false
    }

    //MARK: - Private variables
    fileprivate func _increaseValue() {
        if !(_currentHeight >= 100) {
            _currentHeight += 1
            UserDefaults.setHeight(_currentHeight)
            _stemi.setHeight(UserDefaults.height())
            heightIndicator.text = String(_currentHeight)
        } else {
            _stopSound()
        }
    }

    fileprivate func _decreaseValue() {
        if !(_currentHeight <= 0) {
            _currentHeight -= 1
            UserDefaults.setHeight(_currentHeight)
            _stemi.setHeight(UserDefaults.height())
            heightIndicator.text = String(_currentHeight)
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

    func _stopSound() {
        _movingSound.stop()
        _movingSound.currentTime = 0.0
    }

    //MARK: - Action Handlers
    @IBAction func upArrowActionHandler(_ sender: AnyObject) {
        _movingSound.play()
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(_stopSound), userInfo: nil, repeats: false)
        _increaseValue()
    }

    @IBAction func downButtonActionHandler(_ sender: AnyObject) {
        _movingSound.play()
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(_stopSound), userInfo: nil, repeats: false)
        _decreaseValue()
    }

    @IBAction func upArrowLongPressActionHandler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            _shouldIncrease = false
            _stopSound()
        } else if sender.state == .began {
            _shouldIncrease = true
            _movingSound.play()
            _increaseValueOnLongClick()
        }
    }

    @IBAction func downArrowLongPressActionHandler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            _shouldDecrease = false
            _stopSound()
        } else if sender.state == .began {
            _shouldDecrease = true
            _movingSound.play()
            _decreaseValueOnLongClick()
        }
    }


    @IBAction func doneButtonActionHandler(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
