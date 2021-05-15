//
//  PositionsViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-08-30.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class PositionsViewController: AccountTableViewController<Position>, SymbolControllerPresentable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "PositionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        let title = NSLocalizedString("Positions", comment: "")
        self.title = title
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "position-outline"),
            selectedImage: UIImage(named: "position-fill")
        )
        tabBarItem.accessibilityIdentifier = "Positions"
    }
    
    override func getData(for account: Account, completion: @escaping (Result<[Position], Error>) -> Void) {
        API.quest.positions(for: account.number) { res in
            switch res {
            case .failure(let error): completion(.failure(error))
            case .success(let posRes):
                completion(.success(posRes.positions))
            }
        }
    }
    
    override func cellEvent(name: String, cellData: Position?) {
        if name == PositionTableViewCell.SHOW_SYMBOL {
            presentSymbolCtrl(with: cellData?.symbolId)
        }
    }
}
