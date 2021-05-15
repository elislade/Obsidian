//
//  LocalAuth.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-23.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import Foundation
import LocalAuthentication

struct LocalAuth {
    
    static let main = LocalAuth()
    
    let context = LAContext()
    
    var policyError: NSError?
    var policy: LAPolicy = .deviceOwnerAuthentication
    
    private mutating func setPolicy() {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &policyError) {
            policy = .deviceOwnerAuthenticationWithBiometrics
        }
    }
    
    init() { setPolicy() }
    
    func authorize(reason: String, completion: @escaping(Error?) -> Void ) {
        let reply: (Bool, Error?) -> Void = { success, evaluateError in
            if success {
                completion(nil)
            } else {
                completion(evaluateError)
            }
        }
        
        if let error = policyError {
            completion(error)
        }
        
        let localReason = NSLocalizedString(reason, comment: "")
        context.evaluatePolicy(policy, localizedReason: localReason, reply: reply)
    }
}
