//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        printDebug("Application moved from Not Running to Inactive: \(#function)")
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    
    // MARK: - App Lifecycle
    func applicationDidBecomeActive(_ application: UIApplication) {
        printDebug("Application moved from Inactive to Active: \(#function)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        printDebug("Application moved from Active to Inactive: \(#function)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        printDebug("Application moved from Inactive to Background: \(#function)")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        printDebug("Application moved from Background to Inactive: \(#function)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        printDebug("Application moved from Background to Not Running: \(#function)")
    }
}

