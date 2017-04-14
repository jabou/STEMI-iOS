//
//  AppDelegate.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 23/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UIApplication.shared.setStatusBarHidden(true, with: .none)
        if UserDefaults.firstRun() == false {
            UserDefaults.setIP("192.168.4.1")
            UserDefaults.setFirstRunTrue()
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Connection.StopConnection), object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Connection.StartConnection), object: nil)
    }

}
