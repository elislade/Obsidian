//
//  SymbolView.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-07-01.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class SymbolView: UIView {
    
    @IBOutlet weak var high52Label: UILabel!
    @IBOutlet weak var low52Label: UILabel!
    @IBOutlet weak var volume3MonthsLabel: UILabel!
    @IBOutlet weak var volume20DaysLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var securityLabel: UILabel!
    @IBOutlet weak var dividendLabel: UILabel!
    @IBOutlet weak var dividentExpirationLabel: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var profitExpenseLabel: UILabel!
    @IBOutlet weak var earningsPerShareLabel: UILabel!
    @IBOutlet weak var outstandingSharesLabel: UILabel!
    
    var viewData:Symbol?
    
    func renderViewData() {
        if let symbol = viewData {
            high52Label.text = symbol.highPrice52?.format(as: .currency)
            low52Label.text = symbol.lowPrice52?.format(as: .currency)
            volume3MonthsLabel.text = symbol.averageVol3Months?.formatUsingAbbrevation()
            volume20DaysLabel.text = symbol.averageVol20Days?.formatUsingAbbrevation()
            yieldLabel.text = (symbol.yield / 100).format(as: .percent)
            dividendLabel.text = symbol.dividend.format(as: .currency)
            dividentExpirationLabel.text = symbol.exDate?.format(as: .medium){$0.timeStyle = .none}
            marketCapLabel.text = symbol.marketCap?.formatUsingAbbrevation()
            profitExpenseLabel.text = symbol.pe?.format(as: .decimal)
            earningsPerShareLabel.text = symbol.eps?.format(as: .currency)
            outstandingSharesLabel.text = symbol.outstandingShares?.formatUsingAbbrevation()
            securityLabel.text = symbol.securityType.rawValue
        }
    }
}

extension SymbolView: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        for label in children(ofType: UILabel.self) {
            if label.tag == 1 {
                label.textColor = theme.primaryForegroundColor
            }
            if label.tag == 2 {
                label.textColor = theme.secondaryForegroundColor
            }
        }
    }
}
