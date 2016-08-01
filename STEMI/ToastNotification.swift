//
//  ToastNotification.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 15/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class ToastNotification {
    var mainView: UIView!
    var backgroundView: UIImageView!
    var line: UIImageView!
    var header: UILabel!
    var description: UITextView!
    
    init(onView: UIView, isHint: Bool, headline: String, text: String?, height: CGFloat?){
        
        mainView = onView
   
        if isHint {
            backgroundView = UIImageView(image: UIImage(named: "modeHintBckg"))
            backgroundView.frame = CGRectMake(mainView.frame.size.width/2 - 100, 20, 200, height!)
            backgroundView.alpha = 0
            mainView.addSubview(backgroundView)
            
            header = UILabel(frame: CGRectMake(0, 0, 200, 40))
            header.textAlignment = NSTextAlignment.Center
            header.textColor = UIColor(red: 49/255, green: 48/255, blue: 84/255, alpha: 1.0)
            header.font = UIFont(name: "ProximaNova-Regular", size: 14)
            header.text = headline.uppercaseString
            backgroundView.addSubview(header)
            
            line = UIImageView(image: UIImage(named: "modeHintLine"))
            line.frame = CGRectMake(backgroundView.bounds.size.width/2 - 20, 35, 40, 1)
            backgroundView.addSubview(line)
            
            description = UITextView(frame: CGRectMake(10, 40, 180, 80))
            description.textAlignment = NSTextAlignment.Center
            description.textColor = UIColor(red: 49/255, green: 48/255, blue: 84/255, alpha: 1.0)
            description.backgroundColor = UIColor.clearColor()
            description.font = UIFont(name: "ProximaNova-Regular", size: 10)
            description.text = text!.uppercaseString
            backgroundView.addSubview(description)
        } else {
            backgroundView = UIImageView(image: UIImage(named: "modeEnabledBckg"))
            backgroundView.frame = CGRectMake(mainView.frame.size.width/2 - 100, 20, 200, 40)
            backgroundView.alpha = 0
            mainView.addSubview(backgroundView)
            
            header = UILabel(frame: CGRectMake(0, 0, 200, 40))
            header.textAlignment = NSTextAlignment.Center
            header.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0)
            header.font = UIFont(name: "ProximaNova-Regular", size: 14)
            header.text = headline.uppercaseString + " ENABLED"
            backgroundView.addSubview(header)
        }
    }
    
    func showNotificationWithAutohide(){
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
    
    
    func showNotification(){
        UIView.animateWithDuration(0.2) {
            self.backgroundView.alpha = 1
        }
    }
    
    func hideNotification(){
        UIView.animateWithDuration(0.2, animations: {
            self.backgroundView.alpha = 0
        }) { (Bool) in
            self.backgroundView.removeFromSuperview()
        }
    }
    
    
}
