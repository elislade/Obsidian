//
//  TradingViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-06-17.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class TradingViewController: ViewController<Order> {
    
    var postOrder = PostOrderRequest()
    
    var orderOptionCtrl:TradingOptionsTableViewController? {
        for ctrl in children {
            if let c = ctrl as? TradingOptionsTableViewController {
                return c
            }
        }
        return nil
    }
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Order"
        orderOptionCtrl?.postOrder = postOrder
        orderOptionCtrl?.tradingDelegate = self
        
        buyButton.layer.cornerRadius = 8
        sellButton.layer.cornerRadius = 8
        
        buyButton.isEnabled = false
        sellButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ThemeManager.main.drawTheme(from: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ThemeManager.main.drawTheme(from: self)
    }
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    @IBAction func trade(_ sender: UIButton) {
        postOrder.action = sender == buyButton ? .Buy : .Sell
        API.quest.postOrderImpact(req: postOrder) { res in
            print("res", res)
        }
    }

}

extension TradingViewController: TradingOrderDelegate {
    func didUpdate(order: PostOrderRequest, validity:Bool) {
        postOrder = order
        buyButton.isEnabled = validity
        sellButton.isEnabled = validity
    }
}

extension TradingViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        view.backgroundColor = theme.secondaryBackgroundColor
        buyButton.backgroundColor = theme.primaryBackgroundColor
        sellButton.backgroundColor = theme.primaryBackgroundColor
        orderOptionCtrl?.view.backgroundColor = theme.primaryBackgroundColor
    }
}
