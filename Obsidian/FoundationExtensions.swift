//
//  FoundationExtensions.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-09-28.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    public func setAsLink(textToFind: String, linkURL: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}

extension Date {
    func format(as style: DateFormatter.Style, modify: ((DateFormatter) -> Void)? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .short
        modify?(formatter)
        return formatter.string(from: self)
    }
    
    func formatInterval(toDate date:Date, withStyle style: DateIntervalFormatter.Style) -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .short
        return formatter.string(from: self, to: date)
    }
}

extension Double: NumberAbbrevatable {}
extension Int: NumberAbbrevatable {}

extension String {
    func append(string: String?) -> String {
        if let s = string {
            return self + s
        }
        return self
    }
}

extension Double {
    func format(as style: NumberFormatter.Style, modify: ((NumberFormatter) -> Void)? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        if style == .percent {
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 2
        }
        modify?(formatter)
        if let string = formatter.string(from: (self as NSNumber)) {
            return string
        }
        return "--"
    }
}
