//
//  ScrollTabView.swift
//  Obsidian
//
//  Created by Eli Slade on 2020-09-15.
//  Copyright © 2020 Eli Slade. All rights reserved.
//

import UIKit

class ScrollTabView: UIViewController {
    
    let refCtrl: UIViewController
    
    init(ref: UIViewController){
        refCtrl = ref
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        refCtrl = UIViewController()
        super.init(coder: coder)
    }
    
    @IBOutlet weak var tabImageView: UIImageView!
    @IBOutlet weak var tabLabelView: UILabel!
    @IBOutlet weak var tabContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabImageView.image = refCtrl.tabBarItem.selectedImage
        tabLabelView.text = refCtrl.tabBarItem.title
        refCtrl.view.translatesAutoresizingMaskIntoConstraints = false
        tabContentView.addSubview(refCtrl.view)
        refCtrl.view.constrainBounds(toView: tabContentView)
    }
}
