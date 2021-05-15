//
//  Animation.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-07-07.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit


struct Animation {
    let completion: ((Bool) -> Void)?
    let duration: TimeInterval
    let delay: TimeInterval
    let options: UIView.AnimationOptions
    
    init(withDuration duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, completion: ((Bool) -> Void)? = nil) {
        self.duration = duration
        self.delay = delay
        self.options = options
        self.completion = completion
    }
    
    func run(block: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: block, completion: completion)
    }
}
