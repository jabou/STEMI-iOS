//
//  WalkingStyleViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class WalkingStyleViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var hintTextView: UITextView!

    //MARK: - Public variables
    var walkingStyle: WalkingStyle!

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        hintTextView.editable = true
        hintTextView.font = UIFont(name: "ProximaNova-Regular", size: 13.0)
        hintTextView.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6)
        hintTextView.editable = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        walkingStyle = UserDefaults.walkingStyle()
        _changeHintText(walkingStyle.hashValue)
    }

    // MARK: - Orientation Handling
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    //MARK: - Public methods
    func selectedStyleWithId(identifier: Int) {
        _changeHintText(identifier)
    }

    //MARK: - Private methods
    private func _changeHintText(index: Int) {
        switch index {
        case 0:
            hintTextView.text = Localization.localizedString("WALKING_1")
            UserDefaults.setWalkingStyle(.TripodGait)
        case 1:
            hintTextView.text = Localization.localizedString("WALKING_2")
            UserDefaults.setWalkingStyle(.TripodGaitAngled)
        case 2:
            hintTextView.text = Localization.localizedString("WALKING_3")
            UserDefaults.setWalkingStyle(.TripodGaitStar)
        case 3:
            hintTextView.text = Localization.localizedString("WALKING_4")
            UserDefaults.setWalkingStyle(.WaveGait)
        default:
            break
        }
    }

    //MARK: - Action handlers
    @IBAction func doneButtonActionHandler(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
