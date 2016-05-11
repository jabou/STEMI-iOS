//
//  JoystickViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 23/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import CoreMotion
import STEMIHexapod

class JoystickViewController: UIViewController, LeftJoystickViewDelegate, RightJoystickViewDelegate, MenuViewDelegate {

    //MARK: - UI connection
    //MARK: Buttons
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var standbyButton: UIButton!
    @IBOutlet weak var leftJoystickView: UIView!
    @IBOutlet weak var rightJoystickView: UIView!
    @IBOutlet weak var menuScreenView: UIButton!
    @IBOutlet weak var menuView: UIView!
    
    //MARK: - Public variables
    let selectedPictures = ["movement_sel","rotation_sel","orientation_sel","height_sel","settings_sel"];
    let unselectedPictures = ["movement_non","rotation_non","orientation_non","height_non","settings_non"];

    //MARK: - variables
    var accelerometer: CMMotionManager!
    var accelerometerX: UInt8!
    var accelerometerY: UInt8!
    
    //MARK: - objects
    var stemi: Hexapod!
    var menu: Menu!
    var leftJoystick: LeftJoystickView!
    var rightJoystick: RightJoystickView!
    var enableNotification: EnabledNotification!
    var hintNotification: HintNotification!

    
    //MARK: - Methods
    override func viewDidAppear(animated: Bool) {
        
        leftJoystick = LeftJoystickView(frame: self.leftJoystickView.bounds)
        leftJoystick.delegate = self
        self.leftJoystickView.addSubview(leftJoystick)
        
        rightJoystick = RightJoystickView(frame: self.rightJoystickView.bounds)
        rightJoystick.delegate = self
        self.rightJoystickView.addSubview(rightJoystick)
        
        menu = Menu(frame: self.menuView.bounds)
        menu.delegate = self
        menuDidBecomeInactive()
        self.menuView.addSubview(menu)
        
        stemi = Hexapod()
        startConnection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        //setupButtons()
        //self.buttonCollection[0].selected = true
        standbyButton.setImage(UIImage(named: "standby_off"), forState: .Normal)
        standbyButton.setImage(UIImage(named: "standby_on"), forState: .Selected)
        standbyButton.setImage(UIImage(named: "standby_on"), forState: .Highlighted)
        standbyButton.selected = true
        
        //menuButton.selected = false
        
        accelerometer = CMMotionManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickViewController.stopConnection), name: "StopConnection", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickViewController.startConnection), name: "StartConnection", object: nil)

        
        accelerometer.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
            (data:CMAccelerometerData?, error: NSError?) in
            
            
            
            if let acceleration = data?.acceleration {
                if acceleration.x < -0.4 {
                    self.accelerometerX = 40
                }
                else if acceleration.x > 0.4{
                    self.accelerometerX = 216
                }
                else {
                    if acceleration.x > 0 {
                        self.accelerometerX = UInt8(min(256 - acceleration.x * 100,255))
                    } else {
                        self.accelerometerX = UInt8(-1 * acceleration.x * 100)
                    }
                }
                
                if acceleration.y < -0.4 {
                    self.accelerometerY = 40
                }
                else if acceleration.y > 0.4{
                    self.accelerometerY = 216
                }
                else {
                    if acceleration.y > 0 {
                        self.accelerometerY = UInt8(min(256 - acceleration.y * 100,255))
                    } else {
                        self.accelerometerY = UInt8(-1 * acceleration.y * 100)
                    }
                }
            }
            
            self.stemi.setAccX(self.accelerometerX)
            self.stemi.setAccY(self.accelerometerY)

        }
        
        
        
    }
    
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
            enableNotification = EnabledNotification(onView: self.view, type: "movement")
            enableNotification.showNotification()
            stemi.setMovementMode()
        case "rotation":
            enableNotification = EnabledNotification(onView: self.view, type: "rotation")
            enableNotification.showNotification()
            stemi.setRotationMode()
        case "orientation":
            enableNotification = EnabledNotification(onView: self.view, type: "orientation")
            enableNotification.showNotification()
            stemi.setOrientationMode()
        default:
            print("Mode did not changed!")
        }
        
    }
    
    func menuButtonLongPressOnIndex(index: Int, withState state: UIGestureRecognizerState) {
        
        if state == .Began{
            switch index {
            case 0:
                hintNotification = HintNotification(onView: self.view, headline: "MOVEMENT", text: "ALLOWS LINEAR MOVEMENTS (LEFT, RIGHT, BACK, FORWARD) AND IT CAN BE COMBINED WITH ROTATION MODE. TAP TO ENABLE.", height: 110)
                hintNotification.showNotification()
            case 1:
                hintNotification = HintNotification(onView: self.view, headline: "ROTATION", text: "ALLOWS ROTATIONAL MOVEMENTS AND IT CAN BE COMBINED WITH MOVEMENT OPTION. TAP TO ENABLE.", height: 105)
                hintNotification.showNotification()
            case 2:
                hintNotification = HintNotification(onView: self.view, headline: "ORIENTATION", text: "ALLOWS (napišite vi točno šta radi; treba napomentut da se mobitel može vrtit u raznim smjerovima za upravljanje)... TAP TO ENABLE.", height: 120)
                hintNotification.showNotification()
            case 3:
                hintNotification = HintNotification(onView: self.view, headline: "HEIGHT", text: "TAP MANUALLY  ADJUST THE HEIGHT OF STEMI’S BODY.", height: 90)
                hintNotification.showNotification()
            case 4:
                hintNotification = HintNotification(onView: self.view, headline: "CALIBRATION", text: "TAP TO MANUALLY ADJUST THE POSITION OF EACH JOINT ON EACH LEG.", height: 100)
                hintNotification.showNotification()
            case 5:
                hintNotification = HintNotification(onView: self.view, headline: "WALK STYLES", text: "SWITCH BETWEEN DIFFERENT WALK STYLES.", height: 90)
                hintNotification.showNotification()
            default:
                print("Long press error")
            }
        }
        else if state == .Ended{
            hintNotification.hideNotification()
        }
    }
    
    func leftJoystickDidMove(powerValue: UInt8, angleValue: UInt8) {
        stemi.setJoystickParams(powerValue, angle: angleValue)
    }
    
    func rightJoystickDidMove(rotationValue: UInt8) {
        stemi.setJoystickParams(rotationValue)
    }
    
    func startConnection(){
        stemi.connect()
    }
    
    func stopConnection(){
        stemi.disconnect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Button press handler
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
