
//
//  Constant.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 14/08/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

//MARK: - Constant values
struct Constants {

    static let JoystickSize: CGFloat = 60.0
    static let Rad: CGFloat = 57.2957795
    static let SetHeight = "setHeight"
    static let LongClickSpeed = 0.1

    struct ViewControllers {
        static let ConnectionID = "connection"
        static let JoystickID = "joystick"
        static let ChangeipID = "changeip"
        static let SettingsID = "settings"
        static let HeightID = "height"
        static let WalkingID = "walking"
        static let Calibration = "calibration"
    }

    struct Connection {
        static let StopConnection = "StopConnection"
        static let StartConnection = "StartConnection"
    }

    struct Demo {
        static let DismissView = "DismissView"
    }
}

//MARK: - Localization helper
class Localization {
    static func localizedString(string: String) -> String {
        return NSLocalizedString(string, comment: "Localized String")
    }
}
