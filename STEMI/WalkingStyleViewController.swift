//
//  WalkingStyleViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import STEMIHexapod

class WalkingStyleViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var hintTextView: UITextView!

    //MARK: - Public variables
    var walkingStyle: WalkingStyle!

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        hintTextView.isEditable = true
        hintTextView.font = UIFont(name: "ProximaNova-Regular", size: 13.0)
        hintTextView.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6)
        hintTextView.isEditable = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        walkingStyle = UserDefaults.walkingStyle()
        _changeHintText(walkingStyle.hashValue)
    }

    // MARK: - Orientation Handling
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var shouldAutorotate : Bool {
        return false
    }

    //MARK: - Public methods
    func selectedStyleWithId(_ identifier: Int) {
        _changeHintText(identifier)
    }

    //MARK: - Private methods
    fileprivate func _changeHintText(_ index: Int) {
        switch index {
        case 0:
            hintTextView.text = Localization.localizedString("WALKING_1")
            UserDefaults.setWalkingStyle(.tripodGait)
        case 1:
            hintTextView.text = Localization.localizedString("WALKING_2")
            UserDefaults.setWalkingStyle(.tripodGaitAngled)
        case 2:
            hintTextView.text = Localization.localizedString("WALKING_3")
            UserDefaults.setWalkingStyle(.tripodGaitStar)
        case 3:
            hintTextView.text = Localization.localizedString("WALKING_4")
            UserDefaults.setWalkingStyle(.waveGait)
        default:
            break
        }
    }

    //MARK: - Action handlers
    @IBAction func doneButtonActionHandler(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
