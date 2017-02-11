//
//  RightJoystickView.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 13/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import GLKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol RightJoystickViewDelegate: class {
    func rightJoystickDidMove(_ rotationValue: UInt8)
}

class RightJoystickView: LeftJoystickView {

    //MARK: - Public methods
    weak var rightDelegate: RightJoystickViewDelegate?

    //MARK: - Private methods
    fileprivate var rotationValue: UInt8!

    //MARK: - Setup
    override func setup() {
        Bundle.main.loadNibNamed("RightJoystickView", owner: self, options: nil)
        let width = frame.size.width
        let height = frame.size.height
        self.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.addSubview(self.view)
    }

    //MARK: - Touches Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        maxBound = sqrt(pow(xPosition - centerX, 2))

        UIView.animate(withDuration: 0.20, animations: {
            if (self.maxBound > self.joystickRadius) {
                self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / self.maxBound + self.centerX
                self.joystickView.center = CGPoint(x: self.xPosition, y: self.view.frame.height/2)
            } else {
                self.joystickView.center = CGPoint(x: self.xPosition, y: self.view.frame.height/2)
            }
        }) 

        powerValue = power()

        if angleValue >= 0 {
            rotationValue = UInt8(powerValue)
        } else {
            rotationValue = UInt8(min(256 - powerValue, 255))
        }

        rightDelegate?.rightJoystickDidMove(rotationValue)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        let touch: UITouch = touches.first!
        let position: CGPoint = touch.location(in: self.view)

        xPosition = position.x
        yPosition = position.y

        maxBound = sqrt(pow(xPosition - self.centerX, 2))

        if (self.maxBound > self.joystickRadius) {
            self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / self.maxBound + self.centerX
            self.joystickView.center = CGPoint(x: self.xPosition, y: self.view.frame.height/2)
        } else {
            self.joystickView.center = CGPoint(x: self.xPosition, y: self.view.frame.height/2)
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

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
