//
//  HeightViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class HeightViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var heightIndicator: UILabel!

    //MARK: - Private variables
    private var _stemi: Hexapod!
    private var _currentHeight: Int = 0
    private var _shouldIncrease = false
    private var _shouldDecrease = false

    var counter = 0

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        _currentHeight = Int(UserDefaults.height())
        heightIndicator.text = String(_currentHeight)

        _stemi = Hexapod()
        _stemi.setIP(UserDefaults.IP())
        _stemi.setHeight(UserDefaults.height())
        _stemi.connect()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _stemi.disconnect()
    }

    // MARK: - Orientation Handling
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    //MARK: - Private variables
    private func _increaseValue() {
        if !(_currentHeight >= 100) {
            _currentHeight += 1
            UserDefaults.setHeight(_currentHeight)
            _stemi.setHeight(UserDefaults.height())
            heightIndicator.text = String(_currentHeight)
        }
    }

    private func _decreaseValue() {
        if !(_currentHeight <= 0) {
            _currentHeight -= 1
            UserDefaults.setHeight(_currentHeight)
            _stemi.setHeight(UserDefaults.height())
            heightIndicator.text = String(_currentHeight)
        }
    }

    private func _increaseValueOnLongClick() {
        let dataSendQueue: dispatch_queue_t = dispatch_queue_create("Increase Queue", nil)
        dispatch_async(dataSendQueue, {
            while self._shouldIncrease == true {
                NSThread.sleepForTimeInterval(0.1)
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
                NSThread.sleepForTimeInterval(0.1)
                dispatch_async(dispatch_get_main_queue()) {
                    self._decreaseValue()
                }
            }
        })
    }

    //MARK: - Action Handlers
    @IBAction func upArrowActionHandler(sender: AnyObject) {
        _increaseValue()
    }

    @IBAction func downButtonActionHandler(sender: AnyObject) {
        _decreaseValue()
    }

    @IBAction func upArrowLongPressActionHandler(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            _shouldIncrease = false
        } else if sender.state == .Began {
            _shouldIncrease = true
            _increaseValueOnLongClick()
        }
    }

    @IBAction func downArrowLongPressActionHandler(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            _shouldDecrease = false
        } else if sender.state == .Began {
            _shouldDecrease = true
            _decreaseValueOnLongClick()
        }
    }


    @IBAction func doneButtonActionHandler(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
