//
//  UIResponderExtension.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-09.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit


protocol SetThemable {
    func setTheme(_ theme: Theme, with animation: Animation?)
}

extension SetThemable {
    func setTheme(_ theme: Theme, with animation: Animation? = nil ) {
        
        if let themable = self as? Themeable {
            if let animate = animation {
                animate.run {
                    themable.themeDidUpdate(theme)
                }
            } else {
                themable.themeDidUpdate(theme)
            }
        }
        
        if let app = self as? UIApplication {
            // theme the next responder in the chain which is the appDelegate
            app.next?.setTheme(theme, with: animation)
            
            for window in app.windows {
                window.setTheme(theme, with: animation)
            }
        }
        
        if let window = self as? UIWindow  {
            window.tintColor = theme.system.tintColor
            window.rootViewController?.setTheme(theme, with: animation)
        }
        
        if let ctrl = self as? UIViewController {
            ctrl.presentedViewController?.setTheme(theme, with: animation)
            if #available(iOS 13.0, *) {
                ctrl.presentedViewController?.overrideUserInterfaceStyle = theme.system.userInterfaceStyle
            }
            
            ctrl.presentationController?.setTheme(theme, with: animation)
            ctrl.view.setTheme(theme, with: animation)
            
            for child in ctrl.children {
                child.setTheme(theme, with: animation)
            }
        }
        
        if let view = self as? UIView {
            if !(self is UIWindow) {
                for v in view.subviews {
                    v.setTheme(theme, with: animation)
                }
            }
        }
    }
}

extension UIResponder: SetThemable {
    var theme: Theme {
        return ThemeManager.main.theme
    }
}

extension UIPresentationController: SetThemable {}

extension UITableView: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        separatorColor = theme.secondaryForegroundColor.withAlphaComponent(0.4)
        indicatorStyle = theme.system.scrollViewIndicatorStyle
    }
}

class ThemedEffectView: UIVisualEffectView {}

extension ThemedEffectView: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        if effect is UIBlurEffect {
            effect = UIBlurEffect(style: theme.system.blurEffectStyle)
        }
    }
}

extension UITabBar: Themeable  {
    func themeDidUpdate(_ theme: Theme) {
        if #available(iOS 13.0, *) {} else {
            barStyle = theme.system.barStyle
        }
    }
}

extension UIToolbar: Themeable  {
    func themeDidUpdate(_ theme: Theme) {
        if #available(iOS 13.0, *) {} else {
            barStyle = theme.system.barStyle
        }
    }
}

extension UINavigationBar: Themeable  {
    func themeDidUpdate(_ theme: Theme) {
        if #available(iOS 13.0, *) {} else {
            barStyle = theme.system.barStyle
        }
    }
}

extension UITextField: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        backgroundColor = theme.secondaryBackgroundColor
        textColor = theme.secondaryForegroundColor
    }
}

extension UIPickerView: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        backgroundColor = theme.secondaryBackgroundColor
        
        for label in children(ofType: UILabel.self, toDepth: 8) {
            label.textColor = .red
        }
    }
}
