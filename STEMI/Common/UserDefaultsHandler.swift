//
//  UserDefaultsHandler.swift
//
//
//  Created by Jasmin Abou Aldan on 14/08/16.
//
//

import Foundation
import STEMIHexapod

//MARK: - Private variables
private let FirstRunKey = "firstRun"
private let StemiIPKey = "stemiIP"
private let ThemeKey = "theme"
private let NoStemiKey = "noStemi"
private let StemiIDKey = "stemiId"
private let HardwareVersionKey = "hardwareVersion"
private let WalkingStyleKey = "walkingStyle"
private let HeightKey = "height"

struct UserDefaults {

    // MARK: FirstRun UserDefaults
    static func setFirstRunTrue() {
        let defaults: Foundation.UserDefaults = Foundation.UserDefaults.standard
        defaults.set(true, forKey: FirstRunKey)
        defaults.synchronize()
    }

    static func firstRun() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: FirstRunKey)
    }

    // MARK: IP UserDefaults
    static func setIP(_ address: String) {
        let defaults: Foundation.UserDefaults = Foundation.UserDefaults.standard
        defaults.set(address, forKey: StemiIPKey)
        defaults.synchronize()
    }

    static func IP() -> String {
        if let ip = Foundation.UserDefaults.standard.object(forKey: StemiIPKey) as? String {
            return ip
        } else {
            return ""
        }
    }

    //MARK: StemiName UserDefaults
    static func setStemiName(_ name: String) {
        let defaults: Foundation.UserDefaults = Foundation.UserDefaults.standard
        defaults.set(name, forKey: StemiIDKey)
        defaults.synchronize()
    }

    static func stemiName() -> String {
        if let name = Foundation.UserDefaults.standard.object(forKey: StemiIDKey) as? String {
            return name
        } else {
            return ""
        }
    }

    //MARK: HardwareVersion UserDefaults
    static func setHardwareVersion(_ version: String) {
        let defaults: Foundation.UserDefaults = Foundation.UserDefaults.standard
        defaults.set(version, forKey: HardwareVersionKey)
        defaults.synchronize()
    }

    static func hardwareVersion() ->  String {
        if let version = Foundation.UserDefaults.standard.object(forKey: HardwareVersionKey) as? String {
            return version
        } else {
            return ""
        }
    }

    //MARK: Walking style UserDefaults
    static func setWalkingStyle(_ style: WalkingStyle) {
        let defaults: Foundation.UserDefaults = Foundation.UserDefaults.standard
        defaults.set(style.hashValue, forKey: WalkingStyleKey)
        defaults.synchronize()
    }

    static func walkingStyle() -> WalkingStyle {
        if let styleHash = Foundation.UserDefaults.standard.object(forKey: WalkingStyleKey) as? Int {
            switch styleHash {
            case 0:
                return .tripodGait
            case 1:
                return .tripodGaitAngled
            case 2:
                return .tripodGaitStar
            case 3:
                return .waveGait
            default:
                return .tripodGait
            }
        } else {
            return .tripodGait
        }
    }

    //MARK: Height UserDefaults
    static func setHeight(_ height: Int) {
        let defaults: Foundation.UserDefaults = Foundation.UserDefaults.standard
        defaults.set(height, forKey: HeightKey)
        defaults.synchronize()
    }

    static func height() -> UInt8 {
        return UInt8(Foundation.UserDefaults.standard.integer(forKey: HeightKey))
    }
}
