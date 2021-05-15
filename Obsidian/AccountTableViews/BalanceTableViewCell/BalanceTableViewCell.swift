//
//  BalanceTableViewCell.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-03.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class BalanceTableViewCell: TableViewCell<BalanceResponse> {

    @IBOutlet weak var changeLabel: UILabel!
    
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var maintExcessLabel: UILabel!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var totalEquityLabel: UILabel!
    @IBOutlet weak var marketValueLabel: UILabel!
    
    @IBOutlet weak var cashLabelUsd: UILabel!
    @IBOutlet weak var maintExcessLabelUsd: UILabel!
    @IBOutlet weak var buyingPowerLabelUsd: UILabel!
    @IBOutlet weak var totalEquityLabelUsd: UILabel!
    @IBOutlet weak var marketValueLabelUsd: UILabel!
    
    var shouldCombineBalances = true
    
    override var viewData:BalanceResponse? {
        didSet { renderViewData() }
    }
    
    func renderViewData() {
        guard let balanceRes = viewData else { return }
        let balances = shouldCombineBalances ? balanceRes.combinedBalances : balanceRes.perCurrencyBalances
        if let cadBalance = balances.first(where: { $0.currency == .CAD }) {
            cashLabel.text = cadBalance.cash.format(as: .currency)
            maintExcessLabel.text = cadBalance.maintenanceExcess.format(as: .currency)
            buyingPowerLabel.text = cadBalance.buyingPower.format(as: .currency)
            marketValueLabel.text = cadBalance.marketValue.format(as: .currency)
            totalEquityLabel.text = cadBalance.totalEquity.format(as: .currency)
        }
        
        if let usdBalance = balances.first(where: { $0.currency == .USD }) {
            cashLabelUsd.text = usdBalance.cash.format(as: .currency)
            maintExcessLabelUsd.text = usdBalance.maintenanceExcess.format(as: .currency)
            buyingPowerLabelUsd.text = usdBalance.buyingPower.format(as: .currency)
            marketValueLabelUsd.text = usdBalance.marketValue.format(as: .currency)
            totalEquityLabelUsd.text = usdBalance.totalEquity.format(as: .currency)
        }
        
        if let gains = balanceRes.gains {
            let valueString = gains.value.format(as: .currency)
            let perString = "(\(gains.percent.format(as: .percent)))"
            changeLabel.text = valueString + perString
            changeLabel.textColor = gains.value > 0 ? theme.system.tintColor : gains.value < 0 ? .red : .gray
        }
    }
    
    @IBAction func changeCombinedBalances(_ sender: Any) {
        shouldCombineBalances = !shouldCombineBalances
        renderViewData()
    }
}

extension BalanceTableViewCell: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        if let segCtrl = children(ofType: UISegmentedControl.self).first {
            segCtrl.tintColor = theme.secondaryForegroundColor
        }
        
        for label in children(ofType: UILabel.self, toDepth: 6) {
            if label.tag == 1 {
                label.textColor = theme.primaryForegroundColor
            } else if label.tag == 2 {
                label.textColor = theme.secondaryForegroundColor
            }
        }
    }
}
