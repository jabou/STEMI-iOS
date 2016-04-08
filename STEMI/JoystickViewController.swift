//
//  JoystickViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 23/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import CoreMotion

class JoystickViewController: UIViewController {

    //MARK: - UI connection
    //MARK: Buttons
    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet weak var leftJoystickView: UIView!
    @IBOutlet weak var rightJoystickView: UIView!
    
    //MARK: - Public variables
    let selectedPictures = ["movement_sel","rotation_sel","orientation_sel","height_sel","settings_sel"];
    let unselectedPictures = ["movement_non","rotation_non","orientation_non","height_non","settings_non"];

    //MARK: - Private variables
    private var accelerometer: CMMotionManager!
    private var accelerometerX: UInt8!
    private var accelerometerY: UInt8!
    
    var sendDataToSTEMI: STEMICommunicator!
    private var leftJoystick: LeftJoystickView!
    private var rightJoystick: RightJoystickView!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
        self.buttonCollection[0].selected = true
        
        accelerometer = CMMotionManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickViewController.stopConnection), name: "StopConnection", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickViewController.startConnection), name: "StartConnection", object: nil)

        
        //WARNING: - Provjeriti da se ovo pali/gasi na rotation ili orientation (gdje se to koristi uopće)
        accelerometer.startAccelerometerUpdates()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        leftJoystick = LeftJoystickView(frame: self.leftJoystickView.bounds)
        self.leftJoystickView.addSubview(leftJoystick)
        
        rightJoystick = RightJoystickView(frame: self.rightJoystickView.bounds)
        self.rightJoystickView.addSubview(rightJoystick)
        
        sendDataToSTEMI = STEMICommunicator(connectWithIP: "192.168.4.1", andPort: 80)
        sendDataToSTEMI.mainJoystick = self
        sendDataToSTEMI.leftJoystick = leftJoystick
        sendDataToSTEMI.rightJoystick = rightJoystick
        startConnection()
    }
    
    func startConnection(){
        sendDataToSTEMI.openCommunication = true
        sendDataToSTEMI.dataSend()
    }
    
    func stopConnection(){
        sendDataToSTEMI.openCommunication = false
    }
    
    func getStaticTilt() -> UInt8{
        return buttonCollection[1].selected ? 1 : 0
    }
    
    func getMovingTilt() -> UInt8{
        return buttonCollection[2].selected ? 1 : 0
    }
    
    
    func getAccelerometerX() -> UInt8{
        let fetchedValue = accelerometer.accelerometerData?.acceleration.x
        
        if fetchedValue < -0.4 {
            return 40
        }
        else if fetchedValue > 0.4{
            return 216
        }
        else {
            if fetchedValue > 0 {
                return UInt8(min(256 - fetchedValue! * 100,255))
            } else {
                return UInt8(-1 * fetchedValue! * 100)
            }
        }
    }
    
    func getAccelerometerY() -> UInt8{
        let fetchedValue = accelerometer.accelerometerData?.acceleration.y
        
        if fetchedValue < -0.4 {
            return 40
        }
        else if fetchedValue > 0.4{
            return 216
        }
        else {
            if fetchedValue > 0 {
                return UInt8(min(256 - fetchedValue! * 100,255))
            } else {
                return UInt8(-1 * fetchedValue! * 100)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setupButtons(){
        for i in 0 ..< self.buttonCollection.count {
            let objectUIButton: UIButton = self.buttonCollection[i]
            objectUIButton.setImage(UIImage(named: unselectedPictures[i]), forState: .Normal)
            objectUIButton.setImage(UIImage(named: selectedPictures[i]), forState: .Selected)
            objectUIButton.setImage(UIImage(named: selectedPictures[i]), forState: .Highlighted)
        }
    }
    
    //MARK: Button press handler
    @IBAction func buttonPressed(sender: UIButton){
        
        let index = self.buttonCollection.indexOf(sender)!
        if index >= 0 && index <= 2 {
            for i in 0 ..< 3{
                
                let objectUIButton: UIButton = self.buttonCollection[i]
                objectUIButton.selected = false
                
            }
            sender.selected = true
        }
        else if index == 3 {
            sender.selected = !sender.selected
            
        }
        else if index == 4{

            sender.selected = true
            UIView.animateWithDuration(2.2, animations: {
                sender.highlighted = true
                }, completion: { (done) in
                    sender.selected = false
            })
        }
    }
}















