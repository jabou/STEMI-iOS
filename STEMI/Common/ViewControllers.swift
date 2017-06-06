//
//  ViewControllers.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 15/08/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

// Storyboard
let Storyboard = UIStoryboard(name: "Main", bundle: nil)

struct ViewControllers {
    static let ChangeIPViewController = Storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.ChangeipID)
    static let CheckConnectionViewController = Storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.ConnectionID)
    static let MainJoystickViewController = Storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.JoystickID)
    static let AppSettingsViewController = Storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.SettingsID)
    static let HeightViewController = Storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.HeightID)
    static let WalkingStyleViewController = Storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.WalkingID)
    static let CalibrationViewController = Storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.Calibration)
}
