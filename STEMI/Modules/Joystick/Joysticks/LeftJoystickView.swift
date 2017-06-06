//
//  LeftJoystickView.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 26/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


protocol LeftJoystickViewDelegate: class {
    func leftJoystickDidMove(_ powerValue: UInt8, angleValue: UInt8)
    func rightJoystickDidMove(_ rotationValue: UInt8)
}

class LeftJoystickView: UIView {

    //MARK: - IBOutlet
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var joystickMovingArea: UIView!
    @IBOutlet weak var bottomMark: UIImageView?
    @IBOutlet weak var rightMark: UIImageView!
    @IBOutlet weak var topMark: UIImageView?
    @IBOutlet weak var leftMark: UIImageView!

    //MARK: - Public variables
    weak var leftDelegate: LeftJoystickViewDelegate?
    var joystickView: UIImageView!
    var joystickRadius: CGFloat!
    var maxBound: CGFloat = 0
    var xPosition: CGFloat!
    var yPosition: CGFloat!
    var centerX: CGFloat!
    var centerY: CGFloat!
    var powerValue: CGFloat = 0
    var angleValue: CGFloat = 0
    var leftAlpha: CGFloat = 0
    var rightAlpha: CGFloat = 0

    //MARK: - Private variables
    fileprivate var topAlpha: CGFloat = 0
    fileprivate var bottomAlpha: CGFloat = 0
    fileprivate var lastAngle: CGFloat!
    fileprivate var angleConvert: UInt8!

    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        joystickView = UIImageView(image: UIImage(named:"joystick"))
        centerX = self.view.frame.width/2
        centerY = self.view.frame.height/2
        joystickView.frame = CGRect(x: centerX, y: centerY, width: Constants.JoystickSize, height: Constants.JoystickSize)
        joystickView.center = CGPoint(x: centerX, y: centerY)
        self.view.addSubview(joystickView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MARK: - Setup
    func setup() {
        Bundle.main.loadNibNamed("LeftJoystickView", owner: self, options: nil)
        let width = frame.size.width
        let height = frame.size.height
        self.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.addSubview(self.view)
    }

    //MARK: - Touches Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch: UITouch = touches.first!
        let position: CGPoint = touch.location(in: self.view)

        xPosition = position.x
        yPosition = position.y

        maxBound = sqrt(pow(xPosition - centerX, 2) + pow(yPosition - centerY, 2))
        joystickRadius = self.joystickMovingArea.bounds.width/2

        UIView.animate(withDuration: 0.20, animations: {
            if self.maxBound > self.joystickRadius {
                self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / self.maxBound + self.centerX
                self.yPosition = (self.yPosition - self.centerY) * self.joystickRadius / self.maxBound + self.centerY
                self.joystickView.center = CGPoint(x: self.xPosition, y: self.yPosition)
            } else {
                self.joystickView.center = CGPoint(x: self.xPosition, y: self.yPosition)
            }
        }) 

        let topCenter = CGPoint(x: self.view.frame.width/2, y: self.joystickMovingArea.frame.origin.y)
        let xDistTop = topCenter.x - xPosition
        let yDistTop = topCenter.y - yPosition
        var distanceTop = sqrt(pow(xDistTop, 2) + pow(yDistTop, 2)) / joystickRadius

        let rigthCenter = CGPoint(x: self.view.frame.width - self.joystickMovingArea.frame.origin.x, y: self.view.frame.height/2)
        let xDistRight = rigthCenter.x - xPosition
        let yDistRight = rigthCenter.y - yPosition
        var distanceRight = sqrt(pow(xDistRight, 2) + pow(yDistRight, 2)) / joystickRadius

        let bottomCenter = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - self.joystickMovingArea.frame.origin.y)
        let xDistBottom = bottomCenter.x - xPosition
        let yDistBottom = bottomCenter.y - yPosition
        var distanceBottom = sqrt(pow(xDistBottom, 2) + pow(yDistBottom, 2)) / joystickRadius

        let leftCenter = CGPoint(x: self.joystickMovingArea.frame.origin.x, y: self.view.frame.height/2)
        let xDistLeft = leftCenter.x - xPosition
        let yDistLeft = leftCenter.y - yPosition
        var distanceLeft = sqrt(pow(xDistLeft, 2) + pow(yDistLeft, 2)) / joystickRadius

        if distanceTop > 1 {
            distanceTop = 1
        } else if distanceLeft > 1 {
            distanceLeft = 1
        } else if distanceRight > 1 {
            distanceRight = 1
        } else if distanceBottom > 1 {
            distanceBottom = 1
        }

        topAlpha = 1 - distanceTop
        leftAlpha = 1 - distanceLeft
        rightAlpha = 1 - distanceRight
        bottomAlpha = 1 - distanceBottom

        topMark?.alpha = topAlpha
        bottomMark?.alpha = bottomAlpha
        leftMark.alpha = leftAlpha
        rightMark.alpha = rightAlpha

        powerValue = power()
        angleValue = angle()

        if angleValue >= 0 {
            angleConvert = UInt8(angleValue/2)
        } else {
            angleConvert = UInt8(min(256 + angleValue/2, 255))
        }

        leftDelegate?.leftJoystickDidMove(UInt8(powerValue), angleValue: angleConvert)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch: UITouch = touches.first!
        let position: CGPoint = touch.location(in: self.view)

        xPosition = position.x
        yPosition = position.y

        maxBound = sqrt(pow(xPosition - centerX, 2) + pow(yPosition - centerY, 2))
        joystickRadius = self.joystickMovingArea.bounds.width/2

        if self.maxBound > self.joystickRadius {
            self.xPosition = (self.xPosition - self.centerX) * self.joystickRadius / maxBound + self.centerX
            self.yPosition = (self.yPosition - self.centerY) * self.joystickRadius / maxBound + self.centerY

            self.joystickView.center = CGPoint(x: self.xPosition, y: self.yPosition)
        } else {
            self.joystickView.center = CGPoint(x: self.xPosition, y: self.yPosition)
        }

        let topCenter = CGPoint(x: self.view.frame.width/2, y: self.joystickMovingArea.frame.origin.y)
        let xDistTop = topCenter.x - xPosition
        let yDistTop = topCenter.y - yPosition
        var distanceTop = sqrt(pow(xDistTop, 2) + pow(yDistTop, 2)) / joystickRadius

        let rigthCenter = CGPoint(x: self.view.frame.width - self.joystickMovingArea.frame.origin.x, y: self.view.frame.height/2)
        let xDistRight = rigthCenter.x - xPosition
        let yDistRight = rigthCenter.y - yPosition
        var distanceRight = sqrt(pow(xDistRight, 2) + pow(yDistRight, 2)) / joystickRadius

        let bottomCenter = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - self.joystickMovingArea.frame.origin.y)
        let xDistBottom = bottomCenter.x - xPosition
        let yDistBottom = bottomCenter.y - yPosition
        var distanceBottom = sqrt(pow(xDistBottom, 2) + pow(yDistBottom, 2)) / joystickRadius

        let leftCenter = CGPoint(x: self.joystickMovingArea.frame.origin.x, y: self.view.frame.height/2)
        let xDistLeft = leftCenter.x - xPosition
        let yDistLeft = leftCenter.y - yPosition
        var distanceLeft = sqrt(pow(xDistLeft, 2) + pow(yDistLeft, 2)) / joystickRadius

        if distanceTop > 1 {
            distanceTop = 1
        } else if distanceLeft > 1 {
            distanceLeft = 1
        } else if distanceRight > 1 {
            distanceRight = 1
        } else if distanceBottom > 1 {
            distanceBottom = 1
        }

        topAlpha = 1 - distanceTop
        leftAlpha = 1 - distanceLeft
        rightAlpha = 1 - distanceRight
        bottomAlpha = 1 - distanceBottom

        topMark?.alpha = topAlpha
        bottomMark?.alpha = bottomAlpha
        leftMark.alpha = leftAlpha
        rightMark.alpha = rightAlpha

        powerValue = power()
        angleValue = angle()

        if angleValue >= 0 {
            angleConvert = UInt8(angleValue/2)
        } else {
            angleConvert = UInt8(min(256 + angleValue/2, 255))
        }

        leftDelegate?.leftJoystickDidMove(UInt8(powerValue), angleValue: angleConvert)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        UIView.animate(withDuration: 0.20, animations: {
            self.xPosition = self.centerX
            self.yPosition = self.centerY
            self.joystickView.center = CGPoint(x: self.xPosition, y: self.yPosition)

            self.topMark?.alpha = 0
            self.bottomMark?.alpha = 0
            self.leftMark.alpha = 0
            self.rightMark.alpha = 0
        }) 

        powerValue = power()
        angleValue = angle()

        if angleValue >= 0 {
            angleConvert = UInt8(angleValue/2)
        } else {
            angleConvert = UInt8(min(256 + angleValue/2, 255))
        }

        leftDelegate?.leftJoystickDidMove(UInt8(powerValue), angleValue: angleConvert)
    }

    //MARK: - Angle and power calculation
    func angle() -> CGFloat {
        if xPosition > centerX {
            if yPosition < centerY {
                lastAngle = (atan((yPosition - centerY) / (xPosition - centerX)) * Constants.Rad + 90)
                return lastAngle
            } else if yPosition > centerY {
                lastAngle = (atan((yPosition - centerY) / (xPosition - centerX)) * Constants.Rad) + 90
                return lastAngle
            } else {
                lastAngle = 90
                return lastAngle
            }
        } else if xPosition < centerX {
            if yPosition < centerY {
                lastAngle = (atan((yPosition - centerY) / (xPosition - centerX)) * Constants.Rad - 90)
                return lastAngle
            } else if yPosition > centerY {
                lastAngle = (atan((yPosition - centerY) / (xPosition - centerX)) * Constants.Rad) - 90
                return lastAngle
            } else {
                lastAngle = -90
                return lastAngle
            }
        } else {
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

    func power() -> CGFloat {
        return (100 * sqrt(pow(xPosition - centerX, 2) + pow(yPosition - centerY, 2)) / joystickRadius)
    }

}
