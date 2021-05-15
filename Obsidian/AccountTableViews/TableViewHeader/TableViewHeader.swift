//
//  TableViewHeader.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-01.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

protocol TableViewHeaderDelegate {
    func tap(view:UITableViewHeaderFooterView, section:Int)
}

class TableViewHeaderFooterView<DataType>: UITableViewHeaderFooterView {
    var delegate:TableViewHeaderDelegate?
    var viewData:DataType?
    var section:Int = 0
    var isHighlighted = false
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        ThemeManager.main.drawTheme(from: self)
    }
    
    @objc func tapSection(rec:UIGestureRecognizer) {
        delegate?.tap(view:self, section: section)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSection))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TableViewHeader: TableViewHeaderFooterView<Account>, Themeable {
    
    let cell = TableViewHeaderCell.fromNib()
    let seperator = CALayer()
    
    override var isHighlighted:Bool {
        didSet {
           cell.setHighlighted(isHighlighted, animated: true)
        }
    }
    
    override func tapSection(rec: UIGestureRecognizer) {
        super.tapSection(rec: rec)
        isHighlighted = !isHighlighted
    }
    
    override var viewData:Account? {
        didSet {
           guard let act = viewData else { return }
            cell.textLabel?.text = act.type.rawValue
            cell.detailTextLabel?.text = act.number
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cell.layoutSubviews()
        cell.frame = bounds
        seperator.frame = CGRect(x: 0, y: frame.height - 0.5, width: contentView.frame.width, height: 0.5)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(cell)
        layer.addSublayer(seperator)
        backgroundView = ThemedEffectView(effect: nil)
        isHighlighted = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func themeDidUpdate(_ theme: Theme) {
        seperator.backgroundColor = theme.primaryForegroundColor.withAlphaComponent(0.15).cgColor
    }
    
}
