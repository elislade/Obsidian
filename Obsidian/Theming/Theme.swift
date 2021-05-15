//
//  Theme.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-09.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit


struct Theme {
    var system: UITheme
    
    let primaryBackgroundColor: UIColor
    let secondaryBackgroundColor: UIColor
    let primaryForegroundColor: UIColor
    let secondaryForegroundColor: UIColor
    
    func setAppearances() {
        if #available(iOS 13.0, *) {

        } else {
            UIPageControl.appearance().pageIndicatorTintColor = primaryForegroundColor.withAlphaComponent(0.3)
            UIPageControl.appearance().currentPageIndicatorTintColor = primaryForegroundColor
            UIActivityIndicatorView.appearance().color = secondaryForegroundColor
            UIRefreshControl.appearance().tintColor = secondaryForegroundColor
        }
        UITableViewCell.appearance().backgroundColor = .clear
        //UITableView.appearance().backgroundColor = primaryBackgroundColor
        system.setAppearances()
    }
    
    static let dark = Theme(
        system: UITheme(style: .dark, tintColor: UIColor(red: 0.21, green: 0.85, blue: 0.64, alpha: 1.00)),
        primaryBackgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
        secondaryBackgroundColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1),
        primaryForegroundColor: .white,
        secondaryForegroundColor: .lightGray
    )
    
    static let light = Theme(
        system: UITheme(style: .light, tintColor: UIColor(red: 0.12, green: 0.76, blue: 0.55, alpha: 1.00)),
        primaryBackgroundColor: UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1),
        secondaryBackgroundColor: UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1),
        primaryForegroundColor: UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1),
        secondaryForegroundColor: .gray
    )
}

extension Theme: Equatable {
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        let pbc = lhs.primaryBackgroundColor == rhs.primaryBackgroundColor
        let sbc = lhs.secondaryBackgroundColor == rhs.secondaryBackgroundColor
        let pfc = lhs.primaryForegroundColor == rhs.primaryForegroundColor
        let sfc = lhs.secondaryForegroundColor == rhs.secondaryForegroundColor
        let sys = lhs.system == rhs.system
        return pbc && sbc && pfc && sfc && sys
    }
}
