//
//  AppDelegate.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import UIKit

enum UX {
    static let trainTicketColor = UIColor(red: 255/255, green: 191/255, blue: 206/255, alpha: 1)
    static let highSpeedTicketColor = UIColor(red: 186/255, green: 232/255, blue: 255/255, alpha: 1)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AMapServices.shared().enableHTTPS = true
        AMapServices.shared().apiKey = AMapService.appKey
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

