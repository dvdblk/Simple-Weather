//
//  AppDelegate.swift
//  Dvdblk Weather
//
//  Created by David on 05/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var fullVC: FullViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UILabel.appearance().font = UIFont(name: "CaviarDreams", size: 17)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {
        //refresh on app relaunch
        delay(0.5) {
            self.fullVC?.scrollView.startPullToRefresh()
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {

    }


}

