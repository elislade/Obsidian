//
//  UITheme.swift
//  Stocks
//
//  Created by Eli Slade on 2018-03-28.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit


protocol Themed {
    var theme: Theme? { get set }
}

protocol Themeable {
    func themeDidUpdate(_ theme: Theme)
}

struct UITheme {
    let statusBarStyle: UIStatusBarStyle
    let keyboardAppearance: UIKeyboardAppearance
    let barStyle: UIBarStyle
    let blurEffectStyle: UIBlurEffect.Style
    let tintColor: UIColor
    let scrollViewIndicatorStyle: UIScrollView.IndicatorStyle
    let userInterfaceStyle: UIUserInterfaceStyle
    
    init(style: UIUserInterfaceStyle, tintColor: UIColor) {
        self.userInterfaceStyle = style
        self.barStyle = style == .dark ? .black : .default
        self.blurEffectStyle = style == .dark ? .dark : .light
        self.keyboardAppearance = style == .dark ? .dark : .light
        self.tintColor = tintColor
        self.statusBarStyle = style == .dark ? .lightContent : .default
        self.scrollViewIndicatorStyle = style == .dark ? .white : .black
    }
    
    func setAppearances() {
        if #available(iOS 13.0, *) {} else {
            UINavigationBar.appearance().barStyle = barStyle
            UITabBar.appearance().barStyle = barStyle
            UIToolbar.appearance().barStyle = barStyle
            UISearchBar.appearance().barStyle = barStyle
            UIScrollView.appearance().indicatorStyle = scrollViewIndicatorStyle
            UITextField.appearance().keyboardAppearance = keyboardAppearance
            UISearchBar.appearance().keyboardAppearance = keyboardAppearance
        }
        
        ThemedEffectView.appearance().effect = UIBlurEffect(style: blurEffectStyle)
    }
    
    static let dark = UITheme(style: .dark, tintColor: .orange)
    static let light = UITheme(style: .light, tintColor: .blue)
}

extension UITheme: Equatable {
    static func == (lhs: UITheme, rhs: UITheme) -> Bool {
        let psb = lhs.statusBarStyle == rhs.statusBarStyle
        let key = lhs.keyboardAppearance == rhs.keyboardAppearance
        let bar = lhs.barStyle == rhs.barStyle
        let blur = lhs.blurEffectStyle == rhs.blurEffectStyle
        let tint = lhs.tintColor == rhs.tintColor
        let scroll = lhs.scrollViewIndicatorStyle == rhs.scrollViewIndicatorStyle
        return psb && key && bar && blur && tint && scroll
    }
}
