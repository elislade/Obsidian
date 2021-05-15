//
//  ResponderPickerView.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-06-19.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

protocol ResponderPickerViewDelegate {
    func pickedItem(atIndex index:Int)
}

class ResponderPickerView: UIPickerView {
    
    let toolbar = UIToolbar()
    let titleLable = UILabel()
    let actionButton = UIButton(type: .system)
    
    var actionDelegate:ResponderPickerViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(toolbar)
        toolbar.isUserInteractionEnabled = true
        titleLable.text = "Accounts"
        actionButton.setTitle("Done", for: .normal)
        actionButton.addTarget(self, action: #selector(pickItem), for: .touchUpInside)
        
        let a = UIBarButtonItem(customView: titleLable)
        let b = UIBarButtonItem(customView: actionButton)
        
        toolbar.setItems([a,b], animated: false)
    }
    
    @objc func pickItem() {
        actionDelegate?.pickedItem(atIndex: selectedRow(inComponent: 1))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = false
        let height:CGFloat = 44
        toolbar.frame.size = CGSize(width: frame.width, height: height)
        toolbar.frame.origin.y = -height
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
}
