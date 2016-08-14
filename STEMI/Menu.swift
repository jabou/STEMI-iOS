//
//  Menu.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 09/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import AVFoundation

protocol MenuViewDelegate {
    func menuDidBecomeActive()
    func menuDidBecomeInactive()
    func menuDidChangePlayMode(mode: String)
    func menuButtonLongPressOnIndex(index: Int, withState state: UIGestureRecognizerState)
    func menuButtonDidSelectOnIndex(index: Int)
}

class Menu: UIView {

    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet var longPressCollection: [UILongPressGestureRecognizer]!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var menuActiveIndicator: UIImageView!
    @IBOutlet weak var menuButton: UIButton!

    var delegate: MenuViewDelegate?
    var width: CGFloat!
    var height: CGFloat!

    var soundIn: AVPlayer!
    var soundOut: AVPlayer!

    override init(frame: CGRect) {
        super.init(frame: frame)

        NSBundle.mainBundle().loadNibNamed("Menu", owner: self, options: nil)
        width = frame.size.width
        height = frame.size.height
        self.view.frame = CGRectMake(0, 0, width, height)
        self.addSubview(self.view)

        menuButton.selected = false
        backgroundImage.frame = CGRectMake(self.width/2, self.height, 0, 0)
        backgroundImage.hidden = true
        menuActiveIndicator.alpha = 0
        menuActiveIndicator.hidden = true


        self.buttonCollection[0].selected = true
        for i in 0 ..< buttonCollection.count {
            buttonCollection[i].alpha = 0
            buttonCollection[i].hidden = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func openMenu() {

        menuButton.selected = true
        menuButton.enabled = false
        self.menuActiveIndicator.hidden = false
        self.backgroundImage.hidden = false
        delegate?.menuDidBecomeActive()

        let path = NSBundle.mainBundle().pathForResource("puk", ofType: "wav")
        let url = NSURL(fileURLWithPath: path!)
        soundIn = AVPlayer(URL: url)
        soundIn.play()

        UIView.animateWithDuration(0.15, animations: {
            self.menuActiveIndicator.alpha = 1
            self.menuActiveIndicator.frame = CGRectMake(self.width/2 - self.menuActiveIndicator.bounds.size.width/2, self.height - 78, 75, 60)

        }) {(Bool) in
            UIView.animateWithDuration(0.15, animations: {
                self.menuActiveIndicator.frame = CGRectMake(self.width/2 - self.menuActiveIndicator.bounds.size.width/2, self.height - 68, 75, 60)
                }, completion: nil)
        }

        UIView.animateWithDuration(0.25, animations: {
            self.backgroundImage.alpha = 1
            self.backgroundImage.frame = CGRectMake(0, 0, self.width, self.height)
        }) {(Bool) in
            self.menuButton.enabled = true

            var delay = 0.0

            for i in 0 ..< self.buttonCollection.count {

                self.buttonCollection[i].hidden = false

                UIView.animateWithDuration(0.3, delay: delay, options: .CurveEaseInOut, animations: {
                    self.buttonCollection[i].alpha = 1
                    }, completion: nil)

                delay += 0.03
            }

        }
    }

    func closeMenu() {

        menuButton.selected = false
        menuButton.enabled = false
        delegate?.menuDidBecomeInactive()
        let path = NSBundle.mainBundle().pathForResource("tiu", ofType: "wav")
        let url = NSURL(fileURLWithPath: path!)
        soundOut = AVPlayer(URL: url)

        UIView.animateWithDuration(0.01, animations: {
            self.menuActiveIndicator.frame = CGRectMake(self.width/2 - self.menuActiveIndicator.bounds.size.width/2 - 4, self.height - 68, 75, 60)
            }) { (Bool) in
                UIView.animateWithDuration(0.01, animations: {
                    self.menuActiveIndicator.frame = CGRectMake(self.width/2 - self.menuActiveIndicator.bounds.size.width/2 + 4, self.height - 68, 75, 60)

                    }, completion: { (Bool) in
                        UIView.animateWithDuration(0.01, animations: {
                            self.menuActiveIndicator.frame = CGRectMake(self.width/2 - self.menuActiveIndicator.bounds.size.width/2 - 4, self.height - 68, 75, 60)

                            }, completion: { (Bool) in
                                UIView.animateWithDuration(0.01, animations: {
                                    self.menuActiveIndicator.frame = CGRectMake(self.width/2 - self.menuActiveIndicator.bounds.size.width/2, self.height - 68, 75, 60)

                                    }, completion: { (Bool) in
                                        UIView.animateWithDuration(0.15, animations: {
                                            self.menuActiveIndicator.alpha = 1
                                            self.menuActiveIndicator.frame = CGRectMake(self.width/2 - self.menuActiveIndicator.bounds.size.width/2, self.height - 88, 75, 60)

                                        }) {(Bool) in
                                            UIView.animateWithDuration(0.15, animations: {
                                                self.menuActiveIndicator.frame = CGRectMake(self.width/2 - self.menuActiveIndicator.bounds.size.width/2, self.height - 60, 75, 60)
                                                self.menuActiveIndicator.alpha = 0
                                            }) {(Bool) in
                                            self.menuActiveIndicator.hidden = true
                                            }
                                        }
                                })
                        })
                })
        }

        UIView.animateWithDuration(0.5, animations: {
            self.soundOut.play()
            for i in 0 ..< self.buttonCollection.count {
                self.buttonCollection[i].alpha = 0
            }
            self.backgroundImage.alpha = 0

            }) { (Bool) in
                self.backgroundImage.frame = CGRectMake(self.width/2, self.height, 0, 0)
                self.backgroundImage.hidden = true
                self.menuButton.enabled = true
                for i in 0 ..< self.buttonCollection.count {
                    self.buttonCollection[i].hidden = true
                }
        }
    }


    @IBAction func menuButtonTapped(sender: AnyObject) {

        if menuButton.selected {
            closeMenu()
        } else {
            openMenu()
        }

    }

    @IBAction func buttonLongPressed(sender: UILongPressGestureRecognizer) {
        delegate?.menuButtonLongPressOnIndex(self.longPressCollection.indexOf(sender)!, withState: sender.state)
    }

     @IBAction func buttonPressed(sender: UIButton) {

        let index = self.buttonCollection.indexOf(sender)!
        if index >= 0 && index <= 2 {

            if index == 0 {
                if !sender.selected {
                    delegate?.menuDidChangePlayMode("movement")
                }
                closeMenu()
            } else if index == 1 {
                if !sender.selected {
                    delegate?.menuDidChangePlayMode("rotation")
                }
                closeMenu()
            } else if index == 2 {
                if !sender.selected {
                    delegate?.menuDidChangePlayMode("orientation")
                }
                closeMenu()
            }

            for i in 0 ..< 3 {

                let objectUIButton: UIButton = self.buttonCollection[i]
                objectUIButton.selected = false

            }

            sender.selected = true

        } else {
            delegate?.menuButtonDidSelectOnIndex(index)
            closeMenu()
        }
    }

}
