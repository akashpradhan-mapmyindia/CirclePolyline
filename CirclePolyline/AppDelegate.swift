//
//  AppDelegate.swift
//  CirclePolyline
//
//  Created by MMI on 16/11/23.
//

import UIKit
import MapplsAPICore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        MapplsAccountManager.setMapSDKKey("b340c78affb4b7985d8cd820405c03d2")
        MapplsAccountManager.setRestAPIKey("b340c78affb4b7985d8cd820405c03d2")
        MapplsAccountManager.setClientId("33OkryzDZsLl3oK3-y3-oVmAzZsGx95_J6Wi4-8GSKmiKNQrP63N9cf-b7LtqxG6kxlj3aL3RNGbGc4LG5xvaFNYAOXJ99gU")
        MapplsAccountManager.setClientSecret("lrFxI-iSEg8guc_qKASYZGSASKW-zZrW1mphvEHG770-sk4O09QOMnmAo91BaHs5-oI4OijwF0y40NwFZ4Sean6cVwY-RzcxEH_u23J3Ydk=")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

