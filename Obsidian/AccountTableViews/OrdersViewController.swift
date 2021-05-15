//
//  OrdersViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-10-03.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class OrdersViewController: AccountTableViewController<Order> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "OrderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        let title = NSLocalizedString("Orders", comment: "")
        self.title = title
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "orders-outline"),
            selectedImage: UIImage(named: "orders-fill")
        )
        tabBarItem.accessibilityIdentifier = "Orders"
    }
    
    override func getData(for account: Account, completion: @escaping (Result<[Order], Error>) -> Void) {
        let now = Date()
        let interval = DateInterval(start: Date(timeInterval: -.oneYear, since: now), end: now)
        let req = OrderRequest(accountNumber: account.number, dateInterval: interval)
        
        API.quest.orders(req: req) { res in
            switch res {
            case .failure(let error): completion(.failure(error))
            case .success(let orderRes):
                completion(.success(orderRes.orders.reversed()))
            }
        }
    }
    
}
