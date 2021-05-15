//
//  AppDelegate.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-08-17.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationManager = NotificationManager()
    let securityView = SecurityView.fromNib()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = notificationManager
        window?.rootViewController = RootViewController()
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        API.questAuth.application(application, continue: userActivity, restorationHandler: restorationHandler)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        notificationManager.registerToken(deviceTokenString)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        notificationManager.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //
    }
    
    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) {
        securityView.alpha = 1
        window?.addSubview(securityView)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        API.questAuth.refreshToken()
        
        securityView.fadeOut { _ in
            self.securityView.removeFromSuperview()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}

extension AppDelegate: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        securityView.themeDidUpdate(theme)
    }
}
