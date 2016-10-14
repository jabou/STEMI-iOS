//
//  JoystickViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 23/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//sa

import UIKit
import CoreMotion

enum PlayMode {
    case Movement
    case Rotation
    case Orientation
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
    private let selectedPictures = ["movement_sel", "rotation_sel", "orientation_sel", "height_sel", "settings_sel"]
    private let unselectedPictures = ["movement_non", "rotation_non", "orientation_non", "height_non", "settings_non"]
    private var selectedMode: PlayMode = .Movement
    private var accelerometer: CMMotionManager!
    private var accelerometerX: UInt8!
    private var accelerometerY: UInt8!
    private var stemi: Hexapod!
    private var menu: Menu!
    private var leftJoystick: LeftJoystickView!
    private var rightJoystick: RightJoystickView!
    private var toastNotification: ToastNotification!

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup standby button on screen
        standbyButton.setImage(UIImage(named: "standby_off"), forState: .Normal)
        standbyButton.setImage(UIImage(named: "standby_on"), forState: .Selected)
        standbyButton.setImage(UIImage(named: "standby_on"), forState: .Highlighted)
        standbyButton.selected = true

        //Add notification observers for start and stop connection with stemi
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickViewController.stopConnection), name: Constants.Connection.StopConnection, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickViewController.startConnection), name: Constants.Connection.StartConnection, object: nil)

        //Demo target dismiss view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickViewController.dismissJoystickView), name: Constants.Demo.DismissView, object: nil)
    }

    override func viewDidAppear(animated: Bool) {
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
        stemi = Hexapod()
        stemi.delegate = self
        stemi.setIP(UserDefaults.IP())
        stemi.setHeight(UserDefaults.height())
        stemi.setWalkingStyle(UserDefaults.walkingStyle())
        switch selectedMode {
        case .Movement:
            stemi.setMovementMode()
        case .Rotation:
            stemi.setRotationMode()
        case .Orientation:
            stemi.setOrientationMode()
        }
        startConnection()

        //Declare accelerometer and start takeing values from accelerometer
        accelerometer = CMMotionManager()
        accelerometer.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
            (data: CMAccelerometerData?, error: NSError?) in

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

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stemi.setMovementMode()
        stopConnection()
    }

    // MARK: - Handle orientation
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeRight
    }

    //MARK: - MenuViewDelegate
    func menuDidBecomeActive() {
        self.menuScreenView.hidden = false
        self.view.bringSubviewToFront(self.menuView)
    }

    func menuDidBecomeInactive() {
        self.menuScreenView.hidden = true
        self.view.insertSubview(self.menuView, aboveSubview: self.backgroundView)
    }

    func menuDidChangePlayMode(mode: String) {
        switch mode {
        case "movement":
            toastNotification = ToastNotification(onView: self.view, isHint: false, headline: Localization.localizedString("MOVEMENT"), text: nil, height: nil)
            toastNotification.showNotificationWithAutohide()
            stemi.setMovementMode()
            selectedMode = .Movement
        case "rotation":
            toastNotification = ToastNotification(onView: self.view, isHint: false, headline: Localization.localizedString("ROTATION") , text: nil, height: nil)
            toastNotification.showNotificationWithAutohide()
            stemi.setRotationMode()
            selectedMode = .Rotation
        case "orientation":
            toastNotification = ToastNotification(onView: self.view, isHint: false, headline: Localization.localizedString("ORIENTATION"), text: nil, height: nil)
            toastNotification.showNotificationWithAutohide()
            stemi.setOrientationMode()
            selectedMode = .Orientation
        default:
            #if DEVELOPMENT
                print("Mode did not changed!")
            #endif
        }

    }

    func menuButtonLongPressOnIndex(index: Int, withState state: UIGestureRecognizerState) {
        if state == .Began {
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
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("HEIGHT"), text: Localization.localizedString("HEIGHT_TEXT"), height: 90)
                toastNotification.showNotification()
            case 4:
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("CALIBRATION"), text: Localization.localizedString("CALIBRATION_TEXT"), height: 100)
                toastNotification.showNotification()
            case 5:
                toastNotification = ToastNotification(onView: self.view, isHint: true, headline: Localization.localizedString("WALKING_STYLE"), text: Localization.localizedString("WALKING_STYLE_TEXT"), height: 90)
                toastNotification.showNotification()
            default:
                #if DEVELOPMENT
                    print("Long press error")
                #endif
            }
        } else if state == .Ended {
            toastNotification.hideNotification()
        }
    }

    func menuButtonDidSelectOnIndex(index: Int) {
        switch index {
        case 3:
            self.presentViewController(ViewControllers.HeightViewController, animated: true, completion: nil)
        case 4:
            self.presentViewController(ViewControllers.CalibrationViewController, animated: true, completion: nil)
        case 5:
            self.presentViewController(ViewControllers.WalkingStyleViewController, animated: true, completion: nil)
        case 6:
            self.presentViewController(ViewControllers.AppSettingsViewController, animated: true, completion: nil)
        default:
            break
        }
    }

    //MARK: - LeftJoystickViewDelegate
    func leftJoystickDidMove(powerValue: UInt8, angleValue: UInt8) {
        stemi.setJoystickParams(powerValue, angle: angleValue)
    }

    //MARK: - RightJoystickViewDelegate
    func rightJoystickDidMove(rotationValue: UInt8) {
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
        let warningMessage = UIAlertController(title: Localization.localizedString("CONNECTION_TITLE"), message: Localization.localizedString("CONNECTION_TEXT"), preferredStyle: .Alert)
        let okButton = UIAlertAction(title: Localization.localizedString("OK"), style: .Cancel, handler: {action in
            ViewControllers.MainJoystickViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        warningMessage.addAction(okButton)
        self.presentViewController(warningMessage, animated: true, completion: nil)
    }

    //MARK: - HexapodDelegate
    func connectionStatus(isConnected: Bool) {
        #if DEVELOPMENT
            print("no_hexapod mode. Connetion: \(isConnected)")
        #else
            if isConnected == false {
                connectionLost()
            }
        #endif
    }

    //MARK: - Demo app background handling
    func dismissJoystickView() {
        ViewControllers.MainJoystickViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: - Action Handlers
    @IBAction func menuScreenViewPressed(sender: AnyObject) {
        menu.closeMenu()
    }

    @IBAction func standbyButtonPressed(sender: AnyObject) {
        if standbyButton.selected {
            standbyButton.selected = false
            stemi.turnOff()
        } else {
            standbyButton.selected = true
            stemi.turnOn()
        }
    }
}
