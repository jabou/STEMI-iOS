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

struct UserDefaults {

    // MARK: FirstRun UserDefaults
    static func setFirstRunTrue() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: FirstRunKey)
    }

    static func firstRun() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(FirstRunKey)
    }

    // MARK: IP UserDefaults
    static func setIP(address: String) {
        NSUserDefaults.standardUserDefaults().setObject(address, forKey: StemiIPKey)
    }

    static func IP() -> String {
        if let ip = NSUserDefaults.standardUserDefaults().objectForKey(StemiIPKey) as? String {
            return ip
        } else {
            return ""
        }
    }

    // MARK: Theme UserDefaults
    static func setThemeDark(enabled: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(enabled, forKey: ThemeKey)
    }

    static func themeDark() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(ThemeKey)
    }
}
