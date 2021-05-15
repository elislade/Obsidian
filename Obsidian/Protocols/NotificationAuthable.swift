//
//  NotificationAuthable.swift
//  Obsidian
//
//  Created by Eli Slade on 2019-08-06.
//  Copyright © 2019 Eli Slade. All rights reserved.
//

import UIKit
import UserNotifications

protocol NotificationAuthable: ViewControllerPresentable {}

extension NotificationAuthable {
    var notifyCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }
    
    func checkNotificationAuthStatus() {
        if !ProcessInfo.processInfo.arguments.contains("UITesting") {
            notifyCenter.getNotificationSettings { settings in
                self.handleNotification(status: settings.authorizationStatus)
            }
        }
    }
    
    private func handleNotification(status: UNAuthorizationStatus) {
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        case .denied:
            let titleStr = NSLocalizedString("Enable Notifications!", comment: "")
            let msgStr = NSLocalizedString("Turn on notifications in settings to get daily updates on how you're doing.", comment: "")
            
            let alert = AlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
            //alert.titleImg = UIImage(named: "notify")
            
            let settingsStr = NSLocalizedString("Open Settings", comment: "")
            let settings = UIAlertAction(title: settingsStr, style: .default, handler: { _ in
                UIApplication.shared.openSettings(completion: nil)
            })
            let laterStr = NSLocalizedString("Ask Later", comment: "")
            let later = UIAlertAction(title: laterStr, style: .cancel, handler: nil)
            alert.addAction(later)
            alert.addAction(settings)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion:nil)
            }
        case .notDetermined:
            // Request permission to display alerts and play sounds.
            notifyCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Enable or disable features based on authorization.
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        case .provisional:
            print("provisonal")
        case .ephemeral:
            print("TODO: Fix ephemeral")
        @unknown default:
            fatalError()
        }
    }
}
