//
//  User.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-07-16.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import Foundation
import QuestAPI

struct User: Codable {
    
    private static let LOCAL_KEY = "QUEST_USER"
    
    let id: Int
    var accounts: [Account]
    
    static var shared: User? {
        get {
            guard
                let data = UserDefaults.standard.data(forKey: LOCAL_KEY),
                let user = try? JSONDecoder().decode(User.self, from: data)
            else { return nil }
            
            return user
        }
        
        set(newValue){
            if let d = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(d, forKey: LOCAL_KEY)
            }
        }
    }
    
    init(actRes: AccountResponse) {
        id = actRes.userId
        accounts = actRes.accounts
    }
}
