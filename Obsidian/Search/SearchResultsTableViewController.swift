//
//  SearchResultsTableViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-03-31.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class SearchResultsTableViewController: UITableViewController, UISearchBarDelegate, SymbolControllerPresentable {

    let pageSize = 20
    
    var delegate: SearchResultsDelegate?
    var viewData = [EquitySymbol]()
    var isAnotherPage = true
    var request = SearchRequest(prefix: "", offset: 0)
    var requestTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.backgroundColor = theme.primaryBackgroundColor
        tableView.keyboardDismissMode = .onDrag
        tableView.accessibilityIdentifier = "SearchResults"
        
        let nib = UINib(nibName: "SearchResultTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        themeDidUpdate(theme)
    }
    
    func searchAPI() {
        API.quest.search(req: request){ res in
            switch res {
            case .failure(_): break
            case .success(let searchResponse):
                if searchResponse.symbols.count < self.pageSize {
                    self.isAnotherPage = false
                }
                
                if self.request.offset == 0 {
                    self.viewData.removeAll()
                }
                
                self.viewData.append(contentsOf: searchResponse.symbols)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewData.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(symbol: viewData[indexPath.row])
        presentSymbolCtrl(with: viewData[indexPath.row].symbolId)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell<EquitySymbol>
        cell.viewData = viewData[indexPath.row]
        return cell
    }
 
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewData.count - 1 {
            if isAnotherPage && request.prefix != "" {
                request.offset += pageSize
                searchAPI()
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        requestTimer.invalidate()
        requestTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { _ in
            self.request.prefix = searchText
            self.request.offset = 0
            self.isAnotherPage = true
            self.searchAPI()
        })
    }
}

extension SearchResultsTableViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        tableView.setTheme(theme, with: nil)
        view.backgroundColor = theme.primaryBackgroundColor
    }
}

