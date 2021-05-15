//
//  BalancesViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-09-01.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class BalancesViewController: AccountTableViewController<BalanceResponse> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "BalanceTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        let title = NSLocalizedString("Balances", comment: "")
        self.title = title
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "balance-outline"),
            selectedImage: UIImage(named: "balance-fill")
        )
        tabBarItem.accessibilityIdentifier = "Balances"
    }
    
    override func getData(for account: Account, completion: @escaping (Result<[BalanceResponse], Error>) -> Void) {
        API.quest.balances(for: account.number){ res in
            switch res {
            case .failure(let error): completion(.failure(error))
            case .success(let balanceResponse):
                completion(.success([balanceResponse]))
            }
        }
    }
}
