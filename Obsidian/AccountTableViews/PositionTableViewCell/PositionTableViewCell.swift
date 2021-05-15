//
//  PositionTableViewCell.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-09-30.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class PositionTableViewCell: TableViewCell<Position> {
    
    static let SHOW_SYMBOL = "SHOW_SYMBOL"
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var positionCard: UIView!
    
    @IBOutlet weak var openCloseView: OpenCloseView!
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var symbolDesc: UILabel!
    @IBOutlet weak var symbolPriceButton: UIButton!
    @IBOutlet weak var symbolGains: UILabel!
    
    @IBOutlet weak var averagePrice: UILabel!
    @IBOutlet weak var marketValue: UILabel!
    
    @IBAction func showSymbol(_ sender: Any) {
        triggerEvent(name: PositionTableViewCell.SHOW_SYMBOL)
    }
    
    override var viewData:Position? {
        didSet {
            guard let pos = viewData else { return }
            
            symbolLabel.text = pos.symbol
            
            averagePrice.text = pos.averageEntryPrice.format(as: .currency)
            marketValue.text = pos.currentMarketValue.format(as: .currency)
            
            symbolPriceButton.setTitle(pos.currentPrice.format(as: .currency), for: .normal)
            //symbolDesc.text = "--"
            //symbolGains.text = "--"
            
            openCloseView.closePLLabel.text = pos.closedPnl.format(as: .currency)
            openCloseView.closeQtyLabel.text = "\(pos.closedQuantity)"
            openCloseView.openPLLabel.text = pos.openPnl.format(as: .currency)
            openCloseView.openQtyLabel.text = "\(pos.openQuantity)"
        }
    }
}

extension PositionTableViewCell: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        symbolLabel.textColor = theme.primaryForegroundColor
        
        averagePrice.textColor = theme.secondaryForegroundColor
        marketValue.textColor = theme.secondaryForegroundColor
    }
}
