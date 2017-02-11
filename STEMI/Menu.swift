//
//  Menu.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 09/05/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import AVFoundation

protocol MenuViewDelegate: class {
    func menuDidBecomeActive()
    func menuDidBecomeInactive()
    func menuDidChangePlayMode(_ mode: String)
    func menuButtonLongPressOnIndex(_ index: Int, withState state: UIGestureRecognizerState)
    func menuButtonDidSelectOnIndex(_ index: Int)
}

class Menu: UIView {

    //MARK: - IBOutlets
    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet var longPressCollection: [UILongPressGestureRecognizer]!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var menuActiveIndicator: UIImageView!
    @IBOutlet weak var menuButton: UIButton!

    //MARK: - Public variables
    weak var delegate: MenuViewDelegate?

    //MARK: - Private variables
    fileprivate var width: CGFloat!
    fileprivate var height: CGFloat!
    fileprivate var soundIn: AVAudioPlayer = AVAudioPlayer()
    fileprivate var soundOut: AVAudioPlayer = AVAudioPlayer()

    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)

        Bundle.main.loadNibNamed("Menu", owner: self, options: nil)
        width = frame.size.width
        height = frame.size.height
        self.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.addSubview(self.view)

        menuButton.isSelected = false
        backgroundImage.frame = CGRect(x: self.width/2, y: self.height, width: 0, height: 0)
        backgroundImage.isHidden = true
        menuActiveIndicator.alpha = 0
        menuActiveIndicator.isHidden = true


        self.buttonCollection[0].isSelected = true
        for i in 0 ..< buttonCollection.count {
            buttonCollection[i].alpha = 0
            buttonCollection[i].isHidden = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MARK: - Public methods
    func openMenu() {

        menuButton.isSelected = true
        menuButton.isEnabled = false
        self.menuActiveIndicator.isHidden = false
        self.backgroundImage.isHidden = false
        delegate?.menuDidBecomeActive()

        let path = Bundle.main.path(forResource: "puk", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        do {
            soundIn = try AVAudioPlayer(contentsOf: url)
            soundIn.volume = 0.07
            soundIn.prepareToPlay()
            soundIn.play()
        } catch let error as NSError {
            print(error.description)
        }

        UIView.animate(withDuration: 0.15, animations: {
            self.menuActiveIndicator.alpha = 1
            self.menuActiveIndicator.frame = CGRect(x: self.width/2 - self.menuActiveIndicator.bounds.size.width/2, y: self.height - 78, width: 75, height: 60)

        }, completion: {(Bool) in
            UIView.animate(withDuration: 0.15, animations: {
                self.menuActiveIndicator.frame = CGRect(x: self.width/2 - self.menuActiveIndicator.bounds.size.width/2, y: self.height - 68, width: 75, height: 60)
                }, completion: nil)
        }) 

        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundImage.alpha = 1
            self.backgroundImage.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        }, completion: {(Bool) in
            self.menuButton.isEnabled = true

            var delay = 0.0

            for i in 0 ..< self.buttonCollection.count {

                self.buttonCollection[i].isHidden = false

                UIView.animate(withDuration: 0.3, delay: delay, options: UIViewAnimationOptions(), animations: {
                    self.buttonCollection[i].alpha = 1
                    }, completion: nil)

                delay += 0.03
            }

        }) 
    }

    func closeMenu() {

        menuButton.isSelected = false
        menuButton.isEnabled = false
        delegate?.menuDidBecomeInactive()
        let path = Bundle.main.path(forResource: "tiu", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        do {
            soundOut = try AVAudioPlayer(contentsOf: url)
            soundOut.volume = 0.07
            soundOut.prepareToPlay()
            soundOut.play()
        } catch let error as NSError {
            print(error.description)
        }

        UIView.animate(withDuration: 0.01, animations: {
            self.menuActiveIndicator.frame = CGRect(x: self.width/2 - self.menuActiveIndicator.bounds.size.width/2 - 4, y: self.height - 68, width: 75, height: 60)
            }, completion: { (Bool) in
                UIView.animate(withDuration: 0.01, animations: {
                    self.menuActiveIndicator.frame = CGRect(x: self.width/2 - self.menuActiveIndicator.bounds.size.width/2 + 4, y: self.height - 68, width: 75, height: 60)

                    }, completion: { (Bool) in
                        UIView.animate(withDuration: 0.01, animations: {
                            self.menuActiveIndicator.frame = CGRect(x: self.width/2 - self.menuActiveIndicator.bounds.size.width/2 - 4, y: self.height - 68, width: 75, height: 60)

                            }, completion: { (Bool) in
                                UIView.animate(withDuration: 0.01, animations: {
                                    self.menuActiveIndicator.frame = CGRect(x: self.width/2 - self.menuActiveIndicator.bounds.size.width/2, y: self.height - 68, width: 75, height: 60)

                                    }, completion: { (Bool) in
                                        UIView.animate(withDuration: 0.15, animations: {
                                            self.menuActiveIndicator.alpha = 1
                                            self.menuActiveIndicator.frame = CGRect(x: self.width/2 - self.menuActiveIndicator.bounds.size.width/2, y: self.height - 88, width: 75, height: 60)

                                        }, completion: {(Bool) in
                                            UIView.animate(withDuration: 0.15, animations: {
                                                self.menuActiveIndicator.frame = CGRect(x: self.width/2 - self.menuActiveIndicator.bounds.size.width/2, y: self.height - 60, width: 75, height: 60)
                                                self.menuActiveIndicator.alpha = 0
                                            }, completion: {(Bool) in
                                            self.menuActiveIndicator.isHidden = true
                                            }) 
                                        }) 
                                })
                        })
                })
        }) 

        UIView.animate(withDuration: 0.5, animations: {
            self.soundOut.play()
            for i in 0 ..< self.buttonCollection.count {
                self.buttonCollection[i].alpha = 0
            }
            self.backgroundImage.alpha = 0

            }, completion: { (Bool) in
                self.backgroundImage.frame = CGRect(x: self.width/2, y: self.height, width: 0, height: 0)
                self.backgroundImage.isHidden = true
                self.menuButton.isEnabled = true
                for i in 0 ..< self.buttonCollection.count {
                    self.buttonCollection[i].isHidden = true
                }
        }) 
    }

    //MARK: - Action handlers
    @IBAction func menuButtonTapped(_ sender: AnyObject) {
        if menuButton.isSelected {
            closeMenu()
        } else {
            openMenu()
        }
    }

    @IBAction func buttonLongPressed(_ sender: UILongPressGestureRecognizer) {
        delegate?.menuButtonLongPressOnIndex(self.longPressCollection.index(of: sender)!, withState: sender.state)
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        let index = self.buttonCollection.index(of: sender)!
        if index >= 0 && index <= 2 {
            if index == 0 {
                if !sender.isSelected {
                    delegate?.menuDidChangePlayMode(Localization.localizedString("MOVEMENT"))
                }
                closeMenu()
            } else if index == 1 {
                if !sender.isSelected {
                    delegate?.menuDidChangePlayMode(Localization.localizedString("ROTATION"))
                }
                closeMenu()
            } else if index == 2 {
                if !sender.isSelected {
                    delegate?.menuDidChangePlayMode(Localization.localizedString("ORIENTATION"))
                }
                closeMenu()
            }

            for i in 0 ..< 3 {
                let objectUIButton: UIButton = self.buttonCollection[i]
                objectUIButton.isSelected = false
            }

            sender.isSelected = true
        } else {
            delegate?.menuButtonDidSelectOnIndex(index)
            closeMenu()
        }
    }

}
