//
//  AppDelegate.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 23/03/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Fabric.with([Crashlytics.self])
//        UIApplication.sharedApplication().statusBarHidden = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        if UserDefaults.firstRun() == false {
            UserDefaults.setIP("192.168.4.1")
            UserDefaults.setThemeDark(true)
            UserDefaults.setFirstRunTrue()
        }

        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(StopConnection, object: nil)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(StartConnection, object: nil)
    }

}
