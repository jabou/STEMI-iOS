//
//  EnabledNotification.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 11/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class EnabledNotification{
    
    var mainView: UIView!
    var backgroundView: UIImageView!
    var textLabel: UILabel!
    
    init(onView: UIView, type: String){
        
        mainView = onView
        
        backgroundView = UIImageView(image: UIImage(named: "modeEnabledBckg"))
        backgroundView.frame = CGRectMake(mainView.frame.size.width/2 - 100, 20, 200, 40)
        backgroundView.alpha = 0
        mainView.addSubview(backgroundView)
        
        textLabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0)
        textLabel.font = UIFont(name: "ProximaNova-Regular", size: 14)
        textLabel.text = type.uppercaseString + " ENABLED"
        backgroundView.addSubview(textLabel)
        
        
    }
    
    func showNotification(){
        
        UIView.animateWithDuration(0.2, animations: {
            self.backgroundView.alpha = 1
            }) { (Bool) in
                UIView.animateWithDuration(0.2, delay: 1.0, options: .CurveEaseInOut, animations: {
                    self.backgroundView.alpha = 0
                    }, completion: { (Bool) in
                        self.backgroundView.removeFromSuperview()
                })
        }
    }
    
    
}