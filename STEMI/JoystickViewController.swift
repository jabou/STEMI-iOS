//
//  JoystickViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 23/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class JoystickViewController: UIViewController {

    //MARK: - UI connection
    //MARK: Buttons
    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet weak var leftJoystickView: UIView!
    @IBOutlet weak var rightJoystickView: UIView!
    

    //MARK: - Public variables
    var isMovementSelected: Bool!
    let selectedPictures = ["movement_sel","rotation_sel","orientation_sel","height_sel","settings_sel"];
    let unselectedPictures = ["movement_non","rotation_non","orientation_non","height_non","settings_non"];
    var settingsIsPressed: Bool!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
        self.buttonCollection[0].selected = true
        settingsIsPressed = true
        
        
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        let leftJoystick = LeftJoystickView(frame: self.leftJoystickView.bounds)
        self.leftJoystickView.addSubview(leftJoystick)
        
        let rightJoystick = RightJoystickView(frame: self.rightJoystickView.bounds)
        self.rightJoystickView.addSubview(rightJoystick)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setupButtons(){
        for i in 0 ..< self.buttonCollection.count {
            let objectUIButton: UIButton = self.buttonCollection[i]
            objectUIButton.setImage(UIImage(named: unselectedPictures[i]), forState: .Normal)
            objectUIButton.setImage(UIImage(named: selectedPictures[i]), forState: .Selected)
            objectUIButton.setImage(UIImage(named: selectedPictures[i]), forState: .Highlighted)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
  
    
    //MARK: Button press handler
    @IBAction func buttonPressed(sender: UIButton){
        
        let index = self.buttonCollection.indexOf(sender)!
        if index >= 0 && index <= 2 {
            for i in 0 ..< 3{
                
                let objectUIButton: UIButton = self.buttonCollection[i]
                objectUIButton.selected = false
                
            }
            
            sender.selected = true
        }
        else if index == 3 {
            sender.selected = !sender.selected
            
        }
        else if index == 4{

            sender.selected = true
            UIView.animateWithDuration(2.2, animations: {
                sender.highlighted = true
                }, completion: { (done) in
                    sender.selected = false
            })
            settingsIsPressed = false
        }
        
    }
    
}
