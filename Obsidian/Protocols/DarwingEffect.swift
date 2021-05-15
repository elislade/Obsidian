//
//  DrawingEffect.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-06-06.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

protocol CALayerBacked {
    var layer: CALayer { get }
}

protocol DarwingEffect: CALayerBacked { }

extension DarwingEffect {
    func setShadow(x: CGFloat, y: CGFloat, radius: CGFloat, color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = radius
    }
    
    func setBorder(color: UIColor, width: CGFloat){
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}
