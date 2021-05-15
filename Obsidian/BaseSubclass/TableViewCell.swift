//
//  TableViewCell.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-17.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    func eventOccured(name: String, cellData: Any?)
}

class TableViewCell<DataType>: UITableViewCell {
    var viewData: DataType?
    var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ThemeManager.main.drawTheme(from: self)
        selectionStyle = .none
    }
    
    func triggerEvent(name: String) {
        delegate?.eventOccured(name: name, cellData: viewData)
    }
}
