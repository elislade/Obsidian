//
//  Treeable.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-07-03.
//  Copyright © 2018 Eli Slade. All rights reserved.
//


protocol Treeable {
    associatedtype Branch: Treeable
    
    var parent: Branch? { get }
    var children: [Branch] { get }
}

extension Treeable {
    func children<T>(ofType type: T.Type, toDepth depth: Int = 4) -> [T] {
        if children.count == 0 || depth == 0 {
            return []
        } else {
            var matches = [T]()
            for child in children {
                if let match = child as? T {
                    matches.append(match)
                }
                matches.append(contentsOf: child.children(ofType: type, toDepth: depth - 1))
            }
            return matches
        }
    }
}
