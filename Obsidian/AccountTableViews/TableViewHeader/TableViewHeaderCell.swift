//
//  TableViewHeaderCell.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-05.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

class TableViewHeaderCell: UITableViewCell, Themeable {

    var button: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // grab accessory button/image from view hiarchy
        button = children(ofType: UIButton.self).first
    }
    
    func themeDidUpdate(_ theme: Theme) {
        textLabel?.textColor = theme.primaryForegroundColor
        detailTextLabel?.textColor = theme.secondaryForegroundColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: animated)
        
        let r = CGAffineTransform(rotationAngle: highlighted ? 1.5708 : 0)
        
        func high() { button?.transform = r }

        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseInOut,
                animations:high,
                completion:nil
            )
        } else {
            high()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button?.bounds = CGRect(x: 0, y: 0, width: 8, height: 13)
    }
}
