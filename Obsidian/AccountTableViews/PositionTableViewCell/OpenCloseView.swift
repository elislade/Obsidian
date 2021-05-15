//
//  OpenCloseView.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-09.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

class NibView: UIView {
    @IBOutlet var nibView: UIView!
    
    func setUpNib() {
        //let bundle = Bundle(for: type(of: self))
        backgroundColor = .clear
        UINib(nibName: "\(type(of: self))", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(self.nibView)
        self.nibView.frame = bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpNib()
    }
}

class OpenCloseView: NibView {
    @IBOutlet weak var openQtyLabel: UILabel!
    @IBOutlet weak var openPLLabel: UILabel!
    @IBOutlet weak var closeQtyLabel: UILabel!
    @IBOutlet weak var closePLLabel: UILabel!
}

extension OpenCloseView: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        backgroundColor = theme.secondaryBackgroundColor
        //openCloseView.layer.borderWidth = 0.5
        //openCloseView.layer.borderColor = theme.secondaryForegroundColor.cgColor
        //openCloseView.layer.cornerRadius = 4
        for v in children(ofType: UILabel.self) {
            v.textColor = theme.primaryForegroundColor
        }
        
        for divider in children(ofType: UIView.self).filter({ $0.tag == 21 }) {
            divider.backgroundColor = theme.primaryBackgroundColor
        }
    }
}
