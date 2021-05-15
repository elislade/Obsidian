//
//  ViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-17.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

protocol ViewDatable {
    associatedtype DataType
    var viewData: DataType? {get set}
}

class ViewController<ViewDataType>: UIViewController, ViewDatable {
    var viewData: ViewDataType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 100, height: 300)
    }
}
