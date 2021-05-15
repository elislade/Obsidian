//
//  NewPositionTableViewCell.swift
//  Obsidian
//
//  Created by Eli Slade on 2020-09-03.
//  Copyright © 2020 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class NewPositionTableViewCell: TableViewCell<Position> {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var symbolDetailLabel: UILabel!
    @IBOutlet weak var todayChangeLabel: UILabel!
    @IBOutlet weak var totalChangeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Timer.scheduledTimer(
            timeInterval: 15,
            target: self,
            selector: #selector(checkPriceChange),
            userInfo: nil,
            repeats: true
        )
    }
    
    override var viewData:Position? {
        didSet {
            guard let pos = viewData else { return }
            symbolLabel.text = pos.symbol
            symbolDetailLabel.text = pos.averageEntryPrice.format(as: .currency)
            checkPriceChange()
        }
    }
    
    @objc func checkPriceChange(){
        guard let pos = viewData else { return }
        
        API.quest.quotes(for: pos.symbolId) { res in
            switch res {
            case .failure(let error): print(error.localizedDescription)
            case .success(let posRes):
                guard let q = posRes.quotes.first else { return }
                //let open = q.openPrice.format(as: .currency)
                
                // this calculation is wrong
                let curPrice = q.lastTradePrice ?? pos.currentPrice
                let change = curPrice - q.openPrice
                // ^^
                
                DispatchQueue.main.async {
                    let ch = pos.openPnl / pos.currentMarketValue
                    self.totalChangeLabel.text = pos.openPnl.format(as: .currency) + "(\(ch.format(as: .percent)))"
                    self.totalChangeLabel.textColor = pos.openPnl > 0 ? .green : .red
                    self.todayChangeLabel.text = change.format(as: .currency) + "(\("%"))"
                    self.todayChangeLabel.textColor = change > 0 ? .green : .red
                }
            }
        }
    }
}
