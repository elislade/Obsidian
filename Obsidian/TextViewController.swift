//
//  TextViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-07-13.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

class TextViewController: ViewController<String> {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.dataDetectorTypes = .link
        textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        if let string = viewData {
            textView.text = string
        }
        ThemeManager.main.drawTheme(from: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var size = textView.contentSize
        size.height += (textView.contentInset.top + textView.contentInset.bottom)
        
        let h = UIScreen.main.bounds.height
        if size.height >= h - 90 {
            size.height = h - 90
        }
        
        preferredContentSize = size
        navigationController?.preferredContentSize = preferredContentSize
    }
}

extension TextViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        view.backgroundColor = theme.secondaryBackgroundColor
        textView.textColor = theme.primaryForegroundColor
    }
}
