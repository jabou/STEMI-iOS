//
//  RightJoystickView.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 13/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import GLKit

protocol RightJoystickViewDelegate: class {
    func rightJoystickDidMove(rotationValue: UInt8)
}

class RightJoystickView: LeftJoystickView {

    //MARK: - Public methods
    weak var rightDelegate: RightJoystickViewDelegate?

    //MARK: - Private methods
    private var rotationValue: UInt8!

    //MARK: - Setup
    override func setup() {
        NSBundle.mainBundle().loadNibNamed("RightJoystickView", owner: self, options: nil)
        let width = frame.size.width
        let height = frame.size.height
        self.view.frame = CGRectMake(0, 0, width, height)
        self.addSubview(self.view)
    }

    //MARK: - Touches Handlers
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        maxBound = sqrt(pow(xPosition - centerX, 2))

        UIView.animateWithDuration(0.20) {
            if (self.maxBound > self.joystickRadius) {
                self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / self.maxBound + self.centerX
                self.joystickView.center = CGPointMake(self.xPosition, self.view.frame.height/2)
            } else {
                self.joystickView.center = CGPointMake(self.xPosition, self.view.frame.height/2)
            }
        }

        powerValue = power()

        if angleValue >= 0 {
            rotationValue = UInt8(powerValue)
        } else {
            rotationValue = UInt8(min(256 - powerValue, 255))
        }

        rightDelegate?.rightJoystickDidMove(rotationValue)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)

        let touch: UITouch = touches.first!
        let position: CGPoint = touch.locationInView(self.view)

        xPosition = position.x
        yPosition = position.y

        maxBound = sqrt(pow(xPosition - self.centerX, 2))

        if (self.maxBound > self.joystickRadius) {
            self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / self.maxBound + self.centerX
            self.joystickView.center = CGPointMake(self.xPosition, self.view.frame.height/2)
        } else {
            self.joystickView.center = CGPointMake(self.xPosition, self.view.frame.height/2)
        }

        if angle() < 0 {
            leftAlpha = power()/100
            rightAlpha = 0
        } else {
            leftAlpha = 0
            rightAlpha = power()/100
        }

        leftMark.alpha = leftAlpha
        rightMark.alpha = rightAlpha

        powerValue = power()
        angleValue = angle()

        if angleValue >= 0 {
            rotationValue = UInt8(powerValue)
        } else {
            rotationValue = UInt8(min(256 - powerValue, 255))
        }

        rightDelegate?.rightJoystickDidMove(rotationValue)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)

        powerValue = power()
        if angleValue >= 0 {
            rotationValue = UInt8(powerValue)
        } else {
            rotationValue = UInt8(min(256 - powerValue, 255))
        }

        rightDelegate?.rightJoystickDidMove(rotationValue)
    }

    //MARK: - Power calculation
    override func power() -> CGFloat {
        return (100 * sqrt(pow(xPosition - centerX, 2)) / joystickRadius)
    }

}
