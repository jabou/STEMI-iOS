//
//  LeftJoystickView.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 26/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import GLKit

class LeftJoystickView: UIView {
    
    let JOYSTICK_SIZE: CGFloat = 60.0
    let RAD: CGFloat = 57.2957795
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var joystickMovingArea: UIView!
    @IBOutlet weak var bottomMark: UIImageView!
    @IBOutlet weak var rightMark: UIImageView!
    @IBOutlet weak var topMark: UIImageView!
    @IBOutlet weak var leftMark: UIImageView!
    
    var joystickView: UIImageView!
    var leftAlpha: CGFloat = 0
    var rightAlpha: CGFloat = 0
    var topAlpha: CGFloat = 0
    var bottomAlpha: CGFloat = 0
    var xPosition: CGFloat!
    var yPosition: CGFloat!
    var centerX: CGFloat!
    var centerY: CGFloat!
    var lastAngle: CGFloat!
    var joystickRadius: CGFloat!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        NSBundle.mainBundle().loadNibNamed("LeftJoystickView", owner: self, options: nil)
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
        
        let maxBound = sqrt(pow(xPosition - centerX, 2) + pow(yPosition - centerY, 2))
        joystickRadius = self.joystickMovingArea.bounds.width/2
        
        UIView.animateWithDuration(0.20) {
            if maxBound > self.joystickRadius {
                self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / maxBound + self.centerX
                self.yPosition = (self.yPosition - self.centerY) * self.joystickRadius / maxBound + self.centerY
                
                self.joystickView.center = CGPointMake(self.xPosition, self.yPosition)
            } else {
                self.joystickView.center = CGPointMake(self.xPosition, self.yPosition)
            }
        }
        
       
        
        let topCenter = CGPointMake(self.view.frame.width/2, self.joystickMovingArea.frame.origin.y)
        let xDistTop = topCenter.x - xPosition
        let yDistTop = topCenter.y - yPosition
        var distanceTop = sqrt(pow(xDistTop, 2) + pow(yDistTop, 2)) / joystickRadius
        
        let rigthCenter = CGPointMake(self.view.frame.width - self.joystickMovingArea.frame.origin.x, self.view.frame.height/2)
        let xDistRight = rigthCenter.x - xPosition
        let yDistRight = rigthCenter.y - yPosition
        var distanceRight = sqrt(pow(xDistRight, 2) + pow(yDistRight, 2)) / joystickRadius
        
        let bottomCenter = CGPointMake(self.view.frame.width/2, self.view.frame.height - self.joystickMovingArea.frame.origin.y)
        let xDistBottom = bottomCenter.x - xPosition
        let yDistBottom = bottomCenter.y - yPosition
        var distanceBottom = sqrt(pow(xDistBottom, 2) + pow(yDistBottom, 2)) / joystickRadius
        
        let leftCenter = CGPointMake(self.joystickMovingArea.frame.origin.x, self.view.frame.height/2)
        let xDistLeft = leftCenter.x - xPosition
        let yDistLeft = leftCenter.y - yPosition
        var distanceLeft = sqrt(pow(xDistLeft, 2) + pow(yDistLeft, 2)) / joystickRadius
        
        
        
        if distanceTop > 1 {
            distanceTop = 1
        }
        else if distanceLeft > 1 {
            distanceLeft = 1
        }
        else if distanceRight > 1 {
            distanceRight = 1
        }
        else if distanceBottom > 1 {
            distanceBottom = 1
        }
        
        
        topAlpha = 1 - distanceTop
        leftAlpha = 1 - distanceLeft
        rightAlpha = 1 - distanceRight
        bottomAlpha = 1 - distanceBottom
        
        topMark.alpha = topAlpha
        bottomMark.alpha = bottomAlpha
        leftMark.alpha = leftAlpha
        rightMark.alpha = rightAlpha
        
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let position :CGPoint = touch.locationInView(self.view)
        
        xPosition = position.x
        yPosition = position.y
        
        let maxBound = sqrt(pow(xPosition - centerX, 2) + pow(yPosition - centerY, 2))
        joystickRadius = self.joystickMovingArea.bounds.width/2
        
        if maxBound > self.joystickRadius {
            self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / maxBound + self.centerX
            self.yPosition = (self.yPosition - self.centerY) * self.joystickRadius / maxBound + self.centerY
                
            self.joystickView.center = CGPointMake(self.xPosition, self.yPosition)
        } else {
            self.joystickView.center = CGPointMake(self.xPosition, self.yPosition)
        }
        
        
        
        
        let topCenter = CGPointMake(self.view.frame.width/2, self.joystickMovingArea.frame.origin.y)
        let xDistTop = topCenter.x - xPosition
        let yDistTop = topCenter.y - yPosition
        var distanceTop = sqrt(pow(xDistTop, 2) + pow(yDistTop, 2)) / joystickRadius
        
        let rigthCenter = CGPointMake(self.view.frame.width - self.joystickMovingArea.frame.origin.x, self.view.frame.height/2)
        let xDistRight = rigthCenter.x - xPosition
        let yDistRight = rigthCenter.y - yPosition
        var distanceRight = sqrt(pow(xDistRight, 2) + pow(yDistRight, 2)) / joystickRadius
        
        let bottomCenter = CGPointMake(self.view.frame.width/2, self.view.frame.height - self.joystickMovingArea.frame.origin.y)
        let xDistBottom = bottomCenter.x - xPosition
        let yDistBottom = bottomCenter.y - yPosition
        var distanceBottom = sqrt(pow(xDistBottom, 2) + pow(yDistBottom, 2)) / joystickRadius
        
        let leftCenter = CGPointMake(self.joystickMovingArea.frame.origin.x, self.view.frame.height/2)
        let xDistLeft = leftCenter.x - xPosition
        let yDistLeft = leftCenter.y - yPosition
        var distanceLeft = sqrt(pow(xDistLeft, 2) + pow(yDistLeft, 2)) / joystickRadius
        
        
        
        if distanceTop > 1 {
            distanceTop = 1
        }
        else if distanceLeft > 1 {
            distanceLeft = 1
        }
        else if distanceRight > 1 {
            distanceRight = 1
        }
        else if distanceBottom > 1 {
            distanceBottom = 1
        }
        
        
        topAlpha = 1 - distanceTop
        leftAlpha = 1 - distanceLeft
        rightAlpha = 1 - distanceRight
        bottomAlpha = 1 - distanceBottom
        
        topMark.alpha = topAlpha
        bottomMark.alpha = bottomAlpha
        leftMark.alpha = leftAlpha
        rightMark.alpha = rightAlpha
        

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        UIView.animateWithDuration(0.20) {
            self.xPosition = self.centerX
            self.yPosition = self.centerY
            self.joystickView.center = CGPointMake(self.xPosition, self.yPosition)
            
            self.topMark.alpha = 0
            self.bottomMark.alpha = 0
            self.leftMark.alpha = 0
            self.rightMark.alpha = 0
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
        return (100 * sqrt(pow(xPosition - centerX,2) + pow(yPosition - centerY,2)) / joystickRadius)
    }
    

}
