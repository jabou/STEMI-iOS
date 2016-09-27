//
//  STEMIHexapod.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 07/04/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

//MARK: - Walking styles
public enum WalkingStyle {
    case TripodGait
    case TripodGaitAngled
    case TripodGaitStar
    case WaveGait
    case Error
}

//MARK: - Error types
public enum CalibrationValuesError: ErrorType {
    case OutOfBounds
}

@objc protocol HexapodDelegate: class {
    /**
     Check if app is connected to STEMI.

     -returns: True if stemi is connected and sending data. False if it is not connected or not sending data.
     */
    optional func connectionStatus(isConnected: Bool)
}

public class Hexapod: PacketSenderDelegate {

    //Public variables
    var currPacket: Packet!
    var sendPacket: PacketSender!
    var calibrationPacket: CalibrationPackage!
    var sendCalibrationPacket: CalibrationPacketSender!
    var ipAddress: String!
    var port: Int!
    let slidersArray: [UInt8] = [50, 25, 0, 0, 0, 50, 0, 0, 0, 0, 0]
    var initialCalibrationData: [UInt8] = []
    
    //Delegate
    weak var delegate: HexapodDelegate?

    //MARK: - Hexapod init
    
    ///Initializes defoult connection with IP Address: _192.168.4.1_, and port: _80_
    ///For calibration, use init withCalibrationmode!
    public init(){
        self.ipAddress = "192.168.4.1"
        self.port = 80

        currPacket = Packet()
    }

    /**
     */
    public init(withCalibrationMode: Bool) {
        calibrationModeEnabled = withCalibrationMode
        self.ipAddress = "192.168.4.1"
        self.port = 80
        if calibrationModeEnabled {
            calibrationPacket = CalibrationPackage()
        } else {
            currPacket = Packet()
        }
    }
    
    /**
    Initializes connection with custom IP Address and port
    
    - parameter connectWithIP: Takes IP Address *(def: 192.168.4.1)*
    - parameter andPort: Takes port *(def: 80)*
    */
    public init(connectWithIP: String, andPort: Int){
        ipAddress = connectWithIP
        port = andPort

        currPacket = Packet()
    }
    
    /**
     Change IP Address to new one. By default this is set to _192.168.4.1_
     
    - parameter newIP: Takes new IP Address
     */
    public func setIP(newIP: String){
        ipAddress = newIP
    }

    //MARK: - Hexapod connection handling
    
    /**
     Establish connection with Hexapod. After connection is established, it sends new packet every 200ms.
     */
    public func connect(){
        if calibrationModeEnabled {
            sendCalibrationPacket = CalibrationPacketSender(hexapod: self)
            sendCalibrationPacket.enterToCalibrationMode({ entered in
                if entered {
                    self.initialCalibrationData = self.calibrationPacket.legsValues
                }
            })
        } else {
            sendPacket = PacketSender(hexapod: self)
            sendPacket.delegate = self
            sendPacket.startSendingData()
        }
    }

    /**
     */
    public func connectWithCompletion(complete: (Bool) -> Void) {
        if calibrationModeEnabled {
            sendCalibrationPacket = CalibrationPacketSender(hexapod: self)
            sendCalibrationPacket.enterToCalibrationMode({ entered in
                if entered {
                    self.initialCalibrationData = self.sendCalibrationPacket.legsValuesArray
                    complete(true)
                }
            })
        } else {
            sendPacket = PacketSender(hexapod: self)
            sendPacket.delegate = self
            sendPacket.startSendingData()
            complete(true)
        }
    }
    
    /**
     Stops sending data to Hexapod, and closes connection.
     */
    public func disconnect(){
        if calibrationModeEnabled {
            sendCalibrationPacket.stopSendingData()
        } else {
            sendPacket.stopSendingData()
        }
    }

    //MARK: - Hexapod movement hanlding
    
    /**
     Moves Hexapod forward with max power.
     */
    public func goForward(){
        stopMoving()
        currPacket.power = 100
    }
    
    /**
     Moves Hexapod backward with max power.
     */
    public func goBackward(){
        stopMoving()
        currPacket.power = 100
        currPacket.angle = 90
    }
    
    /**
     Moves Hexapod left with max power.
     */
    public func goLeft(){
        stopMoving()
        currPacket.power = 100
        currPacket.angle = 210
    }
    
    /**
     Moves Hexapod right with max power.
     */
    public func goRight(){
        stopMoving()
        currPacket.power = 100
        currPacket.angle = 45
    }
    
    /**
     Rotate Hexapod left with max power.
     */
    public func turnLeft(){
        stopMoving()
        currPacket.rotation = 156
    }
    
    /**
     Rotate Hexapod right with max power.
     */
    public func turnRight(){
        stopMoving()
        currPacket.rotation = 100
    }
    
    /**
     Turns orientation mode mode on, and tilt Hexapod forward.
     */
    public func tiltForward(){
        setOrientationMode()
        currPacket.accX = 226
    }
    
    /**
     Turns orientation mode mode on, and tilt Hexapod backward.
     */
    public func tiltBackward(){
        setOrientationMode()
        currPacket.accX = 30
    }
    
    /**
     Turns orientation mode mode on, and tilt Hexapod left.
     */
    public func tiltLeft(){
        setOrientationMode()
        currPacket.accY = 226
    }
    
    /**
     Turns orientation mode mode on, and tilt Hexapod right.
     */
    public func tiltRight(){
        setOrientationMode()
        currPacket.accY = 30
    }
    
    /**
     Sets parameters for moving Hexapod with custom Joystick. This is intended for moving the Hexapod: forward, backward , left and right.
     
     _It is proposed for user to use a circular joystick!_
     
     **angle values:** Because Byte values are only positive numbers from 0 to 255, Hexapod gets angle as shown:
     - For angle 0 - 180 you can use 0-90 (original devided by 2)
     - For angle 180 - 360 you can use 166-255 (this can be represented like value from -180 to 0. Logic is same: 255 + (original devided by 2))
     
    - parameter power: Takes values for movement speed (_Values must be: 0-100_)
    - parameter angle: Takes values for angle of moving (_Values can be: 0-255, look at the description!_)
     */
    public func setJoystickParams(power: UInt8, angle: UInt8){
        currPacket.power = power
        currPacket.angle = angle
    }
    
    /**
     Sets parameters for moving Hexapod with custom Joystick. This is intended for rotating the Hexapod left and right.
     
     _It is proposed for user to use a linear (left to right) joystick!_
     
     **angle values:** Because Byte values are only positive numbers from 0 to 255, Hexapod gets rotation as shown:
     - For rotate to right you can use values 0 - 100
     - For rotate to left you can use 255-156 (this can be represented like value from 0 to -100 as 255 - position.)
     
    - parameter rotation: Takes values for rotation speed (_Values must be: 0-255, look at the description!_)
     */
    public func setJoystickParams(rotation: UInt8){
        currPacket.rotation = rotation
    }
    
    /**
     Sets parameters for tilding Hexapod in X direction.
     
     **This value must be max 40!**
     
     **x values:** Because Byte values are only positive numbers from 0 to 255, Hexapod gets x rotation as shown:
     - For tilt forward you can use values 0 - 216 (this can be represented like value from 0 to -100 as 255 - position.)
     - For tilt backward you can use 0 - 100.
     
    - parameter x: Takes values for X tilting (_Values must be: 0-255, look at the description!_)
     */
    public func setAccX(x: UInt8){
        currPacket.accX = x
    }
    
    /**
     Sets parameters for tilding Hexapod in Y direction.
     
     **This value must be max 40!**
     
     **y values:** Because Byte values are only positive numbers from 0 to 255, Hexapod gets y rotation as shown:
     - For tilt left you can use values 0 - 216 (this can be represented like value from 0 to -100 as 255 - position.)
     - For tilt right you can use 0 - 100.
     
    - parameter y: Takes values for Y tilting (_Values must be: 0-255, look at the description!_)
     */
    public func setAccY(y: UInt8){
        currPacket.accY = y
    }
    
    /**
     Stops Hexapod by setting power, angle and rotation to 0.
     */
    public func stopMoving(){
        currPacket.power = 0
        currPacket.angle = 0
        currPacket.rotation = 0
    }
    
    /**
     Resets all Hexapod moving and tilt values to 0.
     */
    public func resetMovingParams(){
        currPacket.power = 0;
        currPacket.angle = 0;
        currPacket.rotation = 0;
        currPacket.staticTilt = 0;
        currPacket.movingTilt = 0;
        currPacket.onOff = 1;
        currPacket.accX = 0;
        currPacket.accY = 0;
    }
    
    /**
     In this mode, Hexapod can move forward, backward, left and right, and it can rotate itself to left and right.
     
     Accelerometer is off.
     */
    public func setMovementMode(){
        currPacket.staticTilt = 0
        currPacket.movingTilt = 0
    }
    
    /**
     In this mode, Hexapod can tilt backward, forward, left and right, and rotate left and right by accelerometer and joystick in place without moving.
     
     Accelerometer is on.
     */
    public func setRotationMode(){
        currPacket.staticTilt = 1
        currPacket.movingTilt = 0
    }
    
    /**
     This is combination of rotation and movement mode, Hexapod can move forward, backward, left and right, and it can rotate itself to left and right. Furthermore the Hexapod can tilt forward, backward, left and right by accelerometer.
     
     Accelerometer is on.
     */
    public func setOrientationMode(){
        currPacket.staticTilt = 0
        currPacket.movingTilt = 1
    }

    //MARK: - Hexapod standby hanling
    
    /**
     Puts Hexapod in standby.
     */
    public func turnOn(){
        currPacket.onOff = 1
    }
    
    /**
     Puts Hexapod out from standby.
     */
    public func turnOff(){
        currPacket.onOff = 0
    }

    //MARK: - Hexapod settings

    /**
     Set hexapod height. This value can be from 0 to 100.
     */
    public func setHeight(height: UInt8) {
        currPacket.height = height
    }

    /**
     Set hexapod walking style. This value can be TripodGait, TripodGaitAngled, TripodGaitStar or WaveGait
     */
    public func setWalkingStyle(style: WalkingStyle) {
        var walkingStyleValue: UInt8!
        switch style.hashValue {
        case 0:
            walkingStyleValue = 30
        case 1:
            walkingStyleValue = 60
        case 2:
            walkingStyleValue = 80
        case 3:
            walkingStyleValue = 100
        default:
            walkingStyleValue = 30
        }
        currPacket.walkingStyle = walkingStyleValue
    }

    //MARK: - Calibration

    /**
     */
    public var calibrationModeEnabled = false

    /**
     */
    public func setValue(value: UInt8, atIndex index: Int) throws {
        if value >= 0 && value <= 100 {
            calibrationPacket.legsValues[index] = value
        } else {
            throw CalibrationValuesError.OutOfBounds
        }
    }

    /**
     */
    public func increaseValueAtIndex(index: Int) {
        if calibrationPacket.legsValues[index] < 100 {
            calibrationPacket.legsValues[index] += 1
        }
    }

    /**
     */
    public func decreaseValueAtIndex(index: Int) {
        if calibrationPacket.legsValues[index] > 0 {
            calibrationPacket.legsValues[index] -= 1
        }
    }

    /**
     */
    public func writeDataToHexapod(complete: (Bool) -> Void) {
        sendCalibrationPacket.stopSendingData()
        NSThread.sleepForTimeInterval(0.5)
        calibrationPacket.writeToHexapod = WriteData.Yes.rawValue
        sendCalibrationPacket.sendOnePackage()
        calibrationPacket.writeToHexapod = WriteData.No.rawValue
        NSThread.sleepForTimeInterval(0.1)
        complete(true)
    }

    /**
     */
    public func fetchDataFromHexapod() -> [UInt8] {
        return initialCalibrationData
    }

    //MARK: - Internal methods for handling connection
    internal func connectionLost() {
        delegate?.connectionStatus!(false)
    }

    internal func connectionActive() {
        delegate?.connectionStatus!(true)
    }
}
