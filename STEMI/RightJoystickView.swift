//
//  RightJoystickView.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 26/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class RightJoystickView: UIView {
    
    let JOYSTICK_SIZE: CGFloat = 60.0
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var joystickMovingArea: UIView!
    @IBOutlet weak var leftMark: UIImageView!
    @IBOutlet weak var rightMark: UIImageView!
    
    
    var joystickView: UIImageView!
    var joystickCenterX: CGFloat!
    var joystickCenterY: CGFloat!
    var leftAlpha: CGFloat = 0
    var rightAlpha: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSBundle.mainBundle().loadNibNamed("RightJoystickView", owner: self, options: nil)
        let width = frame.size.width
        let height = frame.size.height
        self.view.frame = CGRectMake(0, 0, width, height)
        self.addSubview(self.view)
        
        joystickView = UIImageView(image: UIImage(named:"joystick"))
        joystickCenterX = self.view.frame.width/2
        joystickCenterY = self.view.frame.height/2
        joystickView.frame = CGRectMake(joystickCenterX, joystickCenterY, JOYSTICK_SIZE, JOYSTICK_SIZE)
        joystickView.center = CGPointMake(joystickCenterX, joystickCenterY)
        self.view.addSubview(joystickView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let position: CGPoint = touch.locationInView(self.view)
        
        let leftMargin = self.joystickMovingArea.frame.origin.x
        let rightMargin = self.joystickMovingArea.frame.size.width + self.joystickMovingArea.frame.origin.x
        
        if position.x > leftMargin && position.x < rightMargin{
            UIView.animateWithDuration(0.20) {
                self.joystickView.center = CGPointMake(position.x, self.view.frame.height/2)
                let percentage = (self.joystickCenterX - self.joystickView.center.x)/100
                if percentage > 0 {
                    self.rightAlpha = 0.0
                    self.leftAlpha = percentage
                } else {
                    self.leftAlpha = 0.0
                    self.rightAlpha = fabs(percentage)
                }
            }
        }
        else if position.x > rightMargin{
            UIView.animateWithDuration(0.20) {
                self.joystickView.center = CGPointMake(rightMargin, self.view.frame.height/2)
                self.rightAlpha = 1.0
                self.leftAlpha = 0.0
            }
        }
        else if position.x < leftMargin{
            UIView.animateWithDuration(0.20) {
                self.joystickView.center = CGPointMake(leftMargin, self.view.frame.height/2)
                self.rightAlpha = 0.0
                self.leftAlpha = 1.0
            }
        }
        
        self.leftMark.alpha = self.leftAlpha
        self.rightMark.alpha = self.rightAlpha

        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let position :CGPoint = touch.locationInView(self.view)

        let leftMargin = self.joystickMovingArea.frame.origin.x
        let rightMargin = self.joystickMovingArea.frame.size.width + self.joystickMovingArea.frame.origin.x
        
        
        if position.x > leftMargin && position.x < rightMargin{
            UIView.animateWithDuration(0.20) {
                self.joystickView.center = CGPointMake(position.x, self.view.frame.height/2)
                let percentage = (self.joystickCenterX - self.joystickView.center.x)/100
                if percentage > 0 {
                    self.rightAlpha = 0.0
                    self.leftAlpha = percentage
                } else {
                    self.leftAlpha = 0.0
                    self.rightAlpha = fabs(percentage)
                }
            }
        }
        else if position.x > rightMargin{
            UIView.animateWithDuration(0.20) {
                self.joystickView.center = CGPointMake(rightMargin, self.view.frame.height/2)
                self.rightAlpha = 1.0
                self.leftAlpha = 0.0
            }
        }
        else if position.x < leftMargin{
            UIView.animateWithDuration(0.20) {
                self.joystickView.center = CGPointMake(leftMargin, self.view.frame.height/2)
                self.leftAlpha = 1.0
                self.rightAlpha = 0.0
            }
        }
        
        leftMark.alpha = leftAlpha
        rightMark.alpha = rightAlpha
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        UIView.animateWithDuration(0.20) {
            self.joystickView.center = CGPointMake(self.joystickCenterX, self.joystickCenterY)
            self.leftMark.alpha = 0.0
            self.rightMark.alpha = 0.0
        }
    }
    


}
