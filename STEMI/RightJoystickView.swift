//
//  RightJoystickView.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 26/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import GLKit

class RightJoystickView: UIView {
    
    let JOYSTICK_SIZE: CGFloat = 60.0
    let RAD: CGFloat = 57.2957795
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var joystickMovingArea: UIView!
    @IBOutlet weak var leftMark: UIImageView!
    @IBOutlet weak var rightMark: UIImageView!
    
    
    var joystickView: UIImageView!
    var leftAlpha: CGFloat = 0
    var rightAlpha: CGFloat = 0
    var xPosition: CGFloat!
    var yPosition: CGFloat!
    var centerX: CGFloat!
    var centerY: CGFloat!
    var lastAngle: CGFloat!
    var joystickRadius: CGFloat!

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSBundle.mainBundle().loadNibNamed("RightJoystickView", owner: self, options: nil)
        let width = frame.size.width
        let height = frame.size.height
        self.view.frame = CGRectMake(0, 0, width, height)
        self.addSubview(self.view)
        
        joystickView = UIImageView(image: UIImage(named:"joystick"))
        centerX = self.view.frame.width/2
        centerY = self.view.frame.height/2
        joystickView.frame = CGRectMake(centerX, centerY, JOYSTICK_SIZE, JOYSTICK_SIZE)
        joystickView.center = CGPointMake(centerX, centerY)
        self.view.addSubview(joystickView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let position: CGPoint = touch.locationInView(self.view)
        
        xPosition = position.x
        yPosition = position.y
        
        let maxBound = sqrt(pow(xPosition - centerX, 2))
        joystickRadius = self.joystickMovingArea.bounds.width/2
        
        UIView.animateWithDuration(0.20) {
            if (maxBound > self.joystickRadius){
                self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / maxBound + self.centerX
                self.joystickView.center = CGPointMake(self.xPosition, self.view.frame.height/2)
            } else {
                self.joystickView.center = CGPointMake(self.xPosition, self.view.frame.height/2)
            }
        }
        
        if getAngle() < 0{
            leftAlpha = getPower()/100
            rightAlpha = 0
        } else {
            leftAlpha = 0
            rightAlpha = getPower()/100
        }
        self.leftMark.alpha = self.leftAlpha
        self.rightMark.alpha = self.rightAlpha

        
    }
    
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let position :CGPoint = touch.locationInView(self.view)
        
        xPosition = position.x
        yPosition = position.y
        
        let maxBound = sqrt(pow(xPosition - self.centerX, 2))
        joystickRadius = self.joystickMovingArea.bounds.width/2

        UIView.animateWithDuration(0.20) {
            if (maxBound > self.joystickRadius){
                self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / maxBound + self.centerX
                self.joystickView.center = CGPointMake(self.xPosition, self.view.frame.height/2)
            } else {
                self.joystickView.center = CGPointMake(self.xPosition, self.view.frame.height/2)
            }
        }
        
        if getAngle() < 0{
            leftAlpha = getPower()/100
            rightAlpha = 0
        } else {
            leftAlpha = 0
            rightAlpha = getPower()/100
        }
        
        leftMark.alpha = leftAlpha
        rightMark.alpha = rightAlpha
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        UIView.animateWithDuration(0.20) {
            self.xPosition = self.centerX
            self.yPosition = self.centerY
            self.joystickView.center = CGPointMake(self.xPosition, self.yPosition)
            self.leftMark.alpha = 0.0
            self.rightMark.alpha = 0.0
        }
    }
    
    func getAngle() -> CGFloat{
        if xPosition > centerX {
            if yPosition < centerY {
                lastAngle = (atan((yPosition - centerY) / (xPosition - centerX)) * RAD + 90)
                return lastAngle
            }
            else if yPosition > centerY{
                lastAngle = (atan((yPosition - centerY) / (xPosition - centerX)) * RAD) + 90
                return lastAngle
            }
            else {
                lastAngle = 90
                return lastAngle
            }
        }
        else if xPosition < centerX {
            if yPosition < centerY {
                lastAngle = (atan((yPosition - centerY) / (xPosition - centerX)) * RAD - 90)
                return lastAngle
            }
            else if yPosition > centerY {
                lastAngle = (atan((yPosition - centerY) / (xPosition - centerX)) * RAD) - 90
                return lastAngle
            }
            else {
                lastAngle = -90
                return lastAngle
            }
        }
        else {
            if yPosition <= centerY {
                lastAngle = 0
                return lastAngle
            } else {
                if lastAngle < 0 {
                    lastAngle = -180
                    return lastAngle
                } else {
                    lastAngle = 180
                    return lastAngle
                }
            }
        }
    }
 
    func getPower() -> CGFloat {
        return (100 * sqrt(pow(xPosition - centerX, 2)) / joystickRadius)
    }


}
