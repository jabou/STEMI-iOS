//
//  UserDefaultsHandler.swift
//
//
//  Created by Jasmin Abou Aldan on 14/08/16.
//
//

import Foundation

private let FirstRunKey = "firstRun"
private let StemiIPKey = "stemiIP"
private let ThemeKey = "theme"
private let NoStemiKey = "noStemi"
private let StemiIDKey = "stemiId"
private let HardwareVersionKey = "hardwareVersion"

struct UserDefaults {

    // MARK: FirstRun UserDefaults
    static func setFirstRunTrue() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: FirstRunKey)
        defaults.synchronize()
    }

    static func firstRun() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(FirstRunKey)
    }

    // MARK: IP UserDefaults
    static func setIP(address: String) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(address, forKey: StemiIPKey)
        defaults.synchronize()
    }

    static func IP() -> String {
        if let ip = NSUserDefaults.standardUserDefaults().objectForKey(StemiIPKey) as? String {
            return ip
        } else {
            return ""
        }
    }

    //MARK: StemiName UserDefaults
    static func setStemiName(name: String) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(name, forKey: StemiIDKey)
        defaults.synchronize()
    }

    static func stemiName() -> String {
        if let name = NSUserDefaults.standardUserDefaults().objectForKey(StemiIDKey) as? String {
            return name
        } else {
            return ""
        }
    }

    //MARK: HardwareVersion UserDefaults
    static func setHardwareVersion(version: String) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(version, forKey: HardwareVersionKey)
        defaults.synchronize()
    }

    static func hardwareVersion() ->  String {
        if let version = NSUserDefaults.standardUserDefaults().objectForKey(HardwareVersionKey) as? String {
            return version
        } else {
            return ""
        }
    }

}
