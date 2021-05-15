//
//  OrderTableViewCell.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-03.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class OrderTableViewCell: TableViewCell<Order> {

    @IBOutlet weak var stateView: UIView!
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override var viewData: Order? {
        didSet {
            guard let order = viewData else { return }
            
            symbolLabel.text = order.symbol
            
            let color:UIColor = order.state == .Executed ? .green : order.state == .Canceled ? .red : .orange
            stateView.backgroundColor = color
            stateView.layer.cornerRadius = 2
            
            let t = DateFormatter.localizedString(from: order.creationTime, dateStyle: .medium, timeStyle: .short)
            dateLabel.text = t
            
            let orderSide = NSLocalizedString(order.side.description, comment: "")
            
            if let price = order.avgExecPrice {
                descLabel.text = "\(orderSide) \(order.totalQuantity) @ \(price.format(as: .currency))"
            } else {
                let state = NSLocalizedString(order.state.rawValue, comment: "")
                descLabel.text = "\(state) - \(orderSide) \(order.totalQuantity)"
            }
        }
    }

}

extension OrderTableViewCell: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        for primary in [symbolLabel, descLabel] {
            primary?.textColor = theme.primaryForegroundColor
        }
        
        dateLabel.textColor = theme.secondaryForegroundColor
    }
}
