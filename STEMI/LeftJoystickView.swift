//
//  LeftJoystickView.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 26/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class LeftJoystickView: UIView {
    
    let JOYSTICK_SIZE: CGFloat = 60.0
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var joystickMovingArea: UIView!
    var joystickView: UIImageView!
    var joystickCenterX: CGFloat!
    var joystickCenterY: CGFloat!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        NSBundle.mainBundle().loadNibNamed("LeftJoystickView", owner: self, options: nil)
        let width = frame.size.width
        let height = frame.size.height
        self.view.frame = CGRectMake(0, 0, width, height)
        self.addSubview(self.view)
        
        joystickView = UIImageView(image: UIImage(named:"joystick"))
        joystickCenterX = self.view.frame.size.width/2 - joystickView.frame.size.width/2
        joystickCenterY = self.view.frame.size.height/2 - joystickView.frame.size.height/2
        joystickView.frame = CGRectMake(joystickCenterX, joystickCenterY, JOYSTICK_SIZE, JOYSTICK_SIZE)
        self.view.addSubview(joystickView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let position: CGPoint = touch.locationInView(self.view)
        
        UIView.animateWithDuration(0.20) {
            self.joystickView.center = CGPointMake(position.x, position.y)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let position :CGPoint = touch.locationInView(self.view)
        
        //let posX = joystickMovingArea.frame.origin.x
        //let posY = joystickMovingArea.frame.origin.y
        //let x = position.x
        //let y = position.y
        
        //let dx = (x-posX)
        //let dy = (y-posY)
        //let distance = sqrt(dx*dx + dy*dy)
        
        self.joystickView.center = CGPointMake(position.x, position.y)
    
        print("X:\(position.x), Y:\(position.y)")
        
        
        

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        UIView.animateWithDuration(0.20) {
            self.joystickView.frame = CGRectMake(self.joystickCenterX, self.joystickCenterY, self.JOYSTICK_SIZE, self.JOYSTICK_SIZE)
        }
    
    }
    

}
