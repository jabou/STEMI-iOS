//
//  JoystickViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 23/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//sa

import UIKit
import CoreMotion
import STEMIHexapod

enum PlayMode {
    case movement
    case rotation
    case orientation
}

class JoystickViewController: UIViewController, LeftJoystickViewDelegate, RightJoystickViewDelegate, MenuViewDelegate, HexapodDelegate {

    //MARK: - IBOutlets
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var standbyButton: UIButton!
    @IBOutlet weak var leftJoystickView: UIView!
    @IBOutlet weak var rightJoystickView: UIView!
    @IBOutlet weak var menuScreenView: UIButton!
    @IBOutlet weak var menuView: UIView!

    //MARK: - Private vatiables
    fileprivate let selectedPictures = ["movement_sel", "rotation_sel", "orientation_sel", "height_sel", "settings_sel"]
    fileprivate let unselectedPictures = ["movement_non", "rotation_non", "orientation_non", "height_non", "settings_non"]
    fileprivate var selectedMode: PlayMode = .movement
    fileprivate var accelerometer: CMMotionManager!
    fileprivate var accelerometerX: UInt8!
    fileprivate var accelerometerY: UInt8!
    fileprivate var stemi: Hexapod!
    fileprivate var menu: Menu!
    fileprivate var leftJoystick: LeftJoystickView!
    fileprivate var rightJoystick: RightJoystickView!
    fileprivate var toastNotification: ToastNotification!

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stemi = Hexapod()
        stemi.delegate = self
        
        //Setup standby button on screen
        standbyButton.setImage(UIImage(named: "standby_off"), for: UIControlState())
        standbyButton.setImage(UIImage(named: "standby_on"), for: .selected)
        standbyButton.setImage(UIImage(named: "standby_on"), for: .highlighted)
        standbyButton.isSelected = true

        //Add notification observers for start and stop connection with stemi
        NotificationCenter.default.addObserver(self, selector: #selector(JoystickViewController.stopConnection), name: NSNotification.Name(rawValue: Constants.Connection.StopConnection), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JoystickViewController.startConnection), name: NSNotification.Name(rawValue: Constants.Connection.StartConnection), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //Put left joystick on main view
        if leftJoystick == nil {
            leftJoystick = LeftJoystickView(frame: self.leftJoystickView.bounds)
            leftJoystick.leftDelegate = self
            self.leftJoystickView.addSubview(leftJoystick)
        }

        //Put right joystick on main view
        if rightJoystick == nil {
            rightJoystick = RightJoystickView(frame: self.rightJoystickView.bounds)
            rightJoystick.rightDelegate = self
            self.rightJoystickView.addSubview(rightJoystick)
        }

        //Put menu on main view
        if menu == nil {
            menu = Menu(frame: self.menuView.bounds)
            menu.delegate = self
            menuDidBecomeInactive()
            self.menuView.addSubview(menu)
        }

        //Setup stemi, and start connection
        stemi.setIP(UserDefaults.IP())
        stemi.setHeight(UserDefaults.height())
        stemi.setWalkingStyle(UserDefaults.walkingStyle())
        switch selectedMode {
        case .movement:
            stemi.setMovementMode()
        case .rotation:
            stemi.setRotationMode()
        case .orientation:
            stemi.setOrientationMode()
        }
        startConnection()

        //Declare accelerometer and start takeing values from accelerometer
        accelerometer = CMMotionManager()
        accelerometer.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data: CMAccelerometerData?, error: Error?) in
            guard let `self` = self else {
                return
            }

            if let acceleration = data?.acceleration {
                if acceleration.x < -0.4 {
                    self.accelerometerX = 40
                } else if acceleration.x > 0.4 {
                    self.accelerometerX = 216
                } else {
                    if acceleration.x > 0 {
                        self.accelerometerX = UInt8(min(256 - acceleration.x * 100, 255))
                    } else {
                        self.accelerometerX = UInt8(-1 * acceleration.x * 100)
                    }
                }
                if acceleration.y < -0.4 {
                    self.accelerometerY = 40
                } else if acceleration.y > 0.4 {
                    self.accelerometerY = 216
                } else {
                    if acceleration.y > 0 {
                        self.accelerometerY = UInt8(min(256 - acceleration.y * 100, 255))
                    } else {
                        self.accelerometerY = UInt8(-1 * acceleration.y * 100)
                    }
                }
            }
            self.stemi.setAccX(self.accelerometerX)
            self.stemi.setAccY(self.accelerometerY)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stemi.setMovementMode()
        stopConnection()
    }

    // MARK: - Handle orientation
    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }

    //MARK: - MenuViewDelegate
    func menuDidBecomeActive() {
        self.menuScreenView.isHidden = false
        self.view.bringSubview(toFront: self.menuView)
    }

    func menuDidBecomeInactive() {
        self.menuScreenView.isHidden = true
        self.view.insertSubview(self.menuView, aboveSubview: self.backgroundView)
    }

    func menuDidChangePlayMode(_ mode: String) {
        switch mode {
        case "movement":
            toastNotification = ToastNotification(onView: self.view, isHint: false, headline: Localization.localizedString("MOVEMENT"), text: nil, height: nil)
            toastNotification.showNotificationWithAutohide()
            stemi.setMovementMode()
            selectedMode = .movement
        case "rotation":
            toastNotification = ToastNotification(onView: self.view, isHint: false, headline: Localization.localizedString("ROTATION") , text: nil, height: nil)
            toastNotification.showNotificationWithAutohide()
            stemi.setRotationMode()
            selectedMode = .rotation
        case "orientation":
            toastNotification = ToastNotification(onView: self.view, isHint: false, headline: Localization.localizedString("ORIENTATION"), text: nil, height: nil)
            toastNotification.showNotificationWithAutohide()
            stemi.setOrientationMode()
            selectedMode = .orientation
        default:
            #if DEBUG
                print("Mode did not changed!")
            #endif
        }

    }

    func menuButtonLongPressOnIndex(_ index: Int, withState state: UIGestureRecognizerState) {
        if state == .began {
            switch index {
            case 0:
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("MOVEMENT"), text: Localization.localizedString("MOVEMENT_TEXT"), height: 110)
                toastNotification.showNotification()
            case 1:
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("ROTATION"), text: Localization.localizedString("ROTATION_TEXT"), height: 105)
                toastNotification.showNotification()
            case 2:
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("ORIENTATION"), text: Localization.localizedString("ORIENTATION_TEXT"), height: 100)
                toastNotification.showNotification()
            case 3:
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("HEIGHT"), text: Localization.localizedString("HEIGHT_TEXT"), height: 100)
                toastNotification.showNotification()
            case 4:
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("CALIBRATION"), text: Localization.localizedString("CALIBRATION_TEXT"), height: 100)
                toastNotification.showNotification()
            case 5:
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("WALKING_STYLE"), text: Localization.localizedString("WALKING_STYLE_TEXT"), height: 90)
                toastNotification.showNotification()
            default:
                #if DEBUG
                    print("Long press error")
                #endif
            }
        } else if state == .ended {
            toastNotification.hideNotification()
        }
    }

    func menuButtonDidSelectOnIndex(_ index: Int) {
        switch index {
        case 3:
            if stemi.isInStandby() {
                let warningMessage = UIAlertController(title: Localization.localizedString("STANDBY_TITLE"), message: Localization.localizedString("STANDBY_MESSAGE"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: Localization.localizedString("OK"), style: .cancel, handler: nil)
                warningMessage.addAction(okButton)
                self.present(warningMessage, animated: true, completion: nil)
            } else {
                self.present(ViewControllers.HeightViewController, animated: true, completion: nil)
            }
        case 4:
            if stemi.isInStandby() {
                let warningMessage = UIAlertController(title: Localization.localizedString("STANDBY_TITLE"), message: Localization.localizedString("STANDBY_MESSAGE"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: Localization.localizedString("OK"), style: .cancel, handler: nil)
                warningMessage.addAction(okButton)
                self.present(warningMessage, animated: true, completion: nil)
            } else {
                self.present(ViewControllers.CalibrationViewController, animated: true, completion: nil)
            }
        case 5:
            self.present(ViewControllers.WalkingStyleViewController, animated: true, completion: nil)
        case 6:
            let settingsVC = ViewControllers.AppSettingsViewController as! SettingsViewController
            settingsVC.isInStandbyMode = stemi.isInStandby()
            self.present(settingsVC, animated: true, completion: nil)
        default:
            break
        }
    }

    //MARK: - LeftJoystickViewDelegate
    func leftJoystickDidMove(_ powerValue: UInt8, angleValue: UInt8) {
        stemi.setJoystickParams(powerValue, angle: angleValue)
    }

    //MARK: - RightJoystickViewDelegate
    func rightJoystickDidMove(_ rotationValue: UInt8) {
        stemi.setJoystickParams(rotationValue)
    }

    //MARK: - Connection methods
    func startConnection() {
        stemi.connect()
    }

    func stopConnection() {
        stemi.disconnect()
    }

    func connectionLost() {
        let warningMessage = UIAlertController(title: Localization.localizedString("CONNECTION_TITLE"), message: Localization.localizedString("CONNECTION_TEXT"), preferredStyle: .alert)
        let okButton = UIAlertAction(title: Localization.localizedString("OK"), style: .cancel, handler: {action in
            ViewControllers.MainJoystickViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.dismiss(animated: true, completion: nil)
        })
        warningMessage.addAction(okButton)
        self.present(warningMessage, animated: true, completion: nil)
    }

    //MARK: - HexapodDelegate
    func connectionStatus(_ isConnected: Bool) {
        if isConnected == false {
            connectionLost()
        }
    }

    //MARK: - Action Handlers
    @IBAction func menuScreenViewPressed(_ sender: AnyObject) {
        menu.closeMenu()
    }

    @IBAction func standbyButtonPressed(_ sender: AnyObject) {
        if standbyButton.isSelected {
            standbyButton.isSelected = false
            stemi.turnOff()
        } else {
            standbyButton.isSelected = true
            stemi.turnOn()
        }
    }
}
