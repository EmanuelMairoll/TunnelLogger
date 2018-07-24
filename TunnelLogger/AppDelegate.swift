//
//  AppDelegate.swift
//  TunnelLogger
//
//  Created by Emanuel Mairoll on 17.07.18.
//  Copyright © 2018 Emanuel Mairoll. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainController:MainController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(Bundle.main.infoDictionary!["CFBundleShortVersionString"], forKey: "Version Number")

        mainController = MainController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = mainController?.viewController
        window!.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let active = mainController?.remoteControl.active else {
            return
        }
        
        if active {
            mainController?.remoteControl.resumeAudio()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        mainController?.remoteControl.received(event: event)
    }


}

