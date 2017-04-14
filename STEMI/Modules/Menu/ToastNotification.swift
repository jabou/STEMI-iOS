//
//  ToastNotification.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 15/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class ToastNotification {

    //MARK: - Private methods
    fileprivate var mainView: UIView!
    fileprivate var backgroundView: UIImageView!
    fileprivate var line: UIImageView!
    fileprivate var header: UILabel!
    fileprivate var description: UITextView!

    //MARK: - init
    init(onView: UIView, isHint: Bool, headline: String, text: String?, height: CGFloat?) {

        mainView = onView

        if isHint {
            backgroundView = UIImageView(image: UIImage(named: "modeHintBckg"))
            backgroundView.frame = CGRect(x: mainView.frame.size.width/2 - 100, y: 20, width: 200, height: height!)
            backgroundView.alpha = 0
            mainView.addSubview(backgroundView)

            header = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            header.textAlignment = NSTextAlignment.center
            header.textColor = UIColor(red: 49/255, green: 48/255, blue: 84/255, alpha: 1.0)
            header.font = UIFont(name: "ProximaNova-Regular", size: 14)
            header.text = headline.uppercased()
            backgroundView.addSubview(header)

            line = UIImageView(image: UIImage(named: "modeHintLine"))
            line.frame = CGRect(x: backgroundView.bounds.size.width/2 - 20, y: 35, width: 40, height: 1)
            backgroundView.addSubview(line)

            description = UITextView(frame: CGRect(x: 10, y: 40, width: 180, height: 80))
            description.textAlignment = NSTextAlignment.center
            description.textColor = UIColor(red: 49/255, green: 48/255, blue: 84/255, alpha: 1.0)
            description.backgroundColor = UIColor.clear
            description.font = UIFont(name: "ProximaNova-Regular", size: 10)
            description.text = text!.uppercased()
            backgroundView.addSubview(description)
        } else {
            backgroundView = UIImageView(image: UIImage(named: "modeEnabledBckg"))
            backgroundView.frame = CGRect(x: mainView.frame.size.width/2 - 100, y: 20, width: 200, height: 40)
            backgroundView.alpha = 0
            mainView.addSubview(backgroundView)

            header = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            header.textAlignment = NSTextAlignment.center
            header.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 1.0)
            header.font = UIFont(name: "ProximaNova-Regular", size: 14)
            header.text = headline.uppercased() + Localization.localizedString("ENABLED")
            backgroundView.addSubview(header)
        }
    }

    //MARK: - Public methods
    func showNotificationWithAutohide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 1
        }, completion: { (Bool) in
            UIView.animate(withDuration: 0.2, delay: 1.0, options: UIViewAnimationOptions(), animations: {
                self.backgroundView.alpha = 0
                }, completion: { (Bool) in
                    self.backgroundView.removeFromSuperview()
            })
        }) 
    }

    func showNotification() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 1
        }) 
    }

    func hideNotification() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0
        }, completion: { (Bool) in
            self.backgroundView.removeFromSuperview()
        }) 
    }


}
