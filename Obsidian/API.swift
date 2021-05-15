//
//  API.swift
//  Obsidian
//
//  Created by Eli Slade on 2020-11-19.
//  Copyright © 2020 Eli Slade. All rights reserved.
//

import Foundation
import QuestAPI
import Locksmith

public struct KeychainStore: ReadableSecureStorable, CreateableSecureStorable, GenericPasswordSecureStorable, DeleteableSecureStorable {
    
    // Required by GenericPasswordSecureStorable
    public let service: String
    public let account: String
    
    // Required by CreateableSecureStorable
    public var data: [String: Any] = [:]
    
    public init(service: String, account: String, data: [String: Any] = [:]) {
        self.service = service
        self.account = account
        self.data = data
    }
}

class TokenStore: TokenStorable {
    
    var keychain = KeychainStore(service: "Obsidian", account: "Questrade")
    
    func getToken() -> Data {
        guard
            let secure = keychain.readFromSecureStore(),
            let data = secure.data?["data"] as? Data
        else { return Data() }
        
        return data
    }
    
    func setToken(_ token: Data) {
        keychain.data["data"] = token
        try? keychain.updateInSecureStore()
    }
    
}


struct API {
    
    static let quest: QuestAPI = {
        let auth = iOSQuestAuth(
            tokenStore: TokenStore(),
            clientID: "{{client-ID}}",
            redirectURL: "{{URL}}"
        )
        auth.refreshToken()
        return QuestAPI(authorizor: auth)
    }()
    
    static var questAuth: iOSQuestAuth {
        quest.authorizer as! iOSQuestAuth
    }
    
}
