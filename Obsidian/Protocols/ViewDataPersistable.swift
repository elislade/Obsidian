//
//  ViewDataPersistable.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-17.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import Foundation

protocol ViewDataPersistable {
    associatedtype DataType: Codable
    
    var viewData: DataType? { get set }
}

extension ViewDataPersistable {
    
    var viewDataKey: String { "\(Self.self)_\(DataType.self)_viewData" }
    
    func loadViewData(with decoder: JSONDecoder) -> DataType? {
        if let data = UserDefaults.standard.data(forKey: viewDataKey) {
            if let viewData = try? decoder.decode(DataType.self, from: data) {
                return viewData
            }
        }
        return viewData
    }
    
    func persistViewData(with encoder: JSONEncoder) {
        let data = try? encoder.encode(viewData)
        UserDefaults.standard.set(data, forKey: viewDataKey)
    }
}
