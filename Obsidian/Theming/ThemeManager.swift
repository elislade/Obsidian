//
//  ThemeManager.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-09.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit


protocol ThemeManagable: AnyObject {
    var theme: Theme! { get set }
    var previousTheme: Theme? { get set }
}

extension ThemeManagable {
    func set(_ theme: Theme, with animation: Animation? = nil ) {
        previousTheme = theme
        self.theme = theme
        theme.setAppearances()
        UIApplication.shared.setTheme(theme, with: animation)
    }
    
    func drawTheme(from responder: UIResponder = UIApplication.shared) {
        theme.setAppearances()
        responder.setTheme(theme)
    }
    
    func adjustTheme(to brightness: CGFloat) {
        let newTheme: Theme = brightness >= 0.7 ? .light : .dark
        
        if shouldChange(to: newTheme) {
            set(newTheme, with: Animation(withDuration: 0.3, delay: 0, options: .curveEaseOut))
            
            if #available(iOS 13.0, *) {
                UITraitCollection.current = UITraitCollection(userInterfaceStyle: newTheme.system.userInterfaceStyle)
            }
        }
    }
    
    func shouldChange(to theme: Theme) -> Bool {
        if let prevTheme = previousTheme {
            if prevTheme == theme {
                return false
            }
        }
        
        return true
    }
}

class ThemeManager: ThemeManagable {
    
    static var main = ThemeManager(theme: .dark)
    
    var theme: Theme!
    var previousTheme: Theme?
    
    init(theme: Theme) {
        self.theme = theme
    }
}
