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
    static let ChangeIPViewController = Storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllers.ChangeipID)
    static let CheckConnectionViewController = Storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllers.ConnectionID)
    static let MainJoystickViewController = Storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllers.JoystickID)
    static let AppSettingsViewController = Storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllers.SettingsID)
}