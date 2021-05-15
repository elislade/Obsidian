//
//  AppTabBarController.swift
//  Obsidian
//
//  Created by Eli Slade on 2020-09-15.
//  Copyright © 2020 Eli Slade. All rights reserved.
//

import UIKit

final class AppTabBarController: AdaptiveArrayPresentableController<UITabBarController, ScrollTabBarController> {
    
    let a = UINavigationController(rootViewController: PositionsViewController())
    let b = UINavigationController(rootViewController: BalancesViewController())
    let c = UINavigationController(rootViewController: OrdersViewController())
    let d = UINavigationController(rootViewController: SearchViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [a,b,c,d]
    }
}

extension UITabBarController: ControllerArrayPresentable {}
extension ScrollTabBarController: ControllerArrayPresentable {}
