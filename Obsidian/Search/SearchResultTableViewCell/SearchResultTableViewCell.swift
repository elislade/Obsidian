//
//  SearchResultTableViewCell.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-03.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class SearchResultTableViewCell: TableViewCell<EquitySymbol> {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var marketLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override var viewData: EquitySymbol? {
        didSet {
            guard let eSymbol = viewData else { return }
            
            symbolLabel.text = eSymbol.symbol
            marketLabel.text = eSymbol.listingExchange.rawValue
            currencyLabel.text = eSymbol.currency
            descriptionLabel.text = eSymbol.description
        }
    }

}

extension SearchResultTableViewCell: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        symbolLabel.textColor = theme.primaryForegroundColor
        descriptionLabel.textColor = theme.primaryForegroundColor
        marketLabel.textColor = theme.secondaryForegroundColor
        currencyLabel.textColor = theme.secondaryForegroundColor
    }
}
