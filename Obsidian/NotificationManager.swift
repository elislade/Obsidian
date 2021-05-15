//
//  NotificationManager.swift
//  Obsidian
//
//  Created by Eli Slade on 2020-11-18.
//  Copyright © 2020 Eli Slade. All rights reserved.
//

import Foundation
import QuestAPI

class NotificationManager: NSObject {
    
    func registerToken(_ token: String) {
        var r = URLRequest(url: URL(string: "https://notify.services/register")!)
        
        r.httpBody = try! JSONSerialization.data(withJSONObject: ["deviceToken" : token, "clientSecret": "{{some secret}}"])
        r.httpMethod = "POST"
        r.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        r.setValue(UserAgent.main, forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: r){ data, res, err in
            if let error = err {
                print("err", error.localizedDescription)
            } else {
                print("token registration successful")
            }
        }.resume()
    }
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        if let aps = userInfo["aps"] as? [String:Any] {
            if let cat = aps["category"] as? String {
                if cat == "eod-recap" {
                    eodBalanceRecapNotification(completionHandler)
                    return
                }
            }
        }
        
        completionHandler(.failed)
    }
    
    private func getEmojiResponse(from percentageChange: Double) -> String {
        if percentageChange == 0 { return "😐" }
        
        let positiveEmoji = ["🙂","😊","😎","😀","😁","🤑"]
        let negitiveEmoji = ["🙁","😟","😢","😭","🤮","🤬"]
        let emojiStep = 0.02 // 2%
        
        let emoji = percentageChange > 0 ? positiveEmoji : negitiveEmoji
        var index = Int(abs(percentageChange) / emojiStep)
        if index > emoji.count - 1 {
            index = emoji.count - 1
        }
        return emoji[index]
    }
    
    
    private func eodBalanceRecapNotification(_ completion:@escaping (UIBackgroundFetchResult) -> Void ) {
        guard let user = User.shared else {
            completion(.failed)
            return
        }
        
        var actBalPairs = [(act: Account, bal: BalanceResponse)]()
        
        let dispatchDelay: Double = UIDevice.current.userInterfaceIdiom == .pad ? 15 : 0
            
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchDelay, execute: {
            API.quest.authorizer.refreshToken { err in
                if let _ = err {
                    completion(.failed)
                } else {
                    for act in user.accounts {
                        API.quest.balances(for: act.number){ res in
                            switch res {
                            case .failure(_): completion(.failed);
                            case .success(let res):
                                actBalPairs.append((act, res))
                                
                                if actBalPairs.count == user.accounts.count {
                                    send()
                                }
                            }
                        }
                    }
                }
            }
        })
        
        func send() {
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            let titleStr = NSLocalizedString("How you did today", comment: "")
            content.title = titleStr
            content.badge = 1
            content.sound = UNNotificationSound.default
            
            actBalPairs.sort(by: { a, b in a.act.number > b.act.number })
            
            for pair in actBalPairs {
                if let gains = pair.bal.gains {
                    let emoji = getEmojiResponse(from: gains.percent)
                    let account = pair.act.type.rawValue
                    let value = gains.value.format(as: .currency)
                    let percent = gains.percent.format(as: .percent)
                    content.body += "\(emoji) \(account): \(value)(\(percent))"
                    if pair != actBalPairs.last! {
                      content.body += "\n"
                    }
                }
            }
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
            center.add(request){(error) in
                if let _ = error {
                    completion(.failed)
                } else {
                    completion(.newData)
                }
            }
        }
        
    }
    
}


extension NotificationManager: UNUserNotificationCenterDelegate {
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
