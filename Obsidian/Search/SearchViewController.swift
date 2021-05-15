//
//  SearchViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-09-01.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

protocol SearchResultsDelegate {
    func didSelect(symbol:EquitySymbol)
}

class SearchViewController: ViewController<[EquitySymbol]>, ViewDataPersistable, UITableViewDataSource, UITableViewDelegate, SymbolControllerPresentable {
    
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: view.bounds, style: .grouped)
        tb.dataSource = self
        tb.delegate = self
        tb.backgroundColor = .clear
        tb.tableFooterView = UIView()
        tb.register(
            UINib(nibName: "SearchResultTableViewCell", bundle: nil),
            forCellReuseIdentifier: "cell"
        )
        return tb
    }()
    
    lazy var searchController: UISearchController = {
        let results = SearchResultsTableViewController()
        results.delegate = self
        let ctrl = UISearchController(searchResultsController: results)
        ctrl.searchBar.delegate = results
        // ctrl.searchBar.showsSearchResultsButton = true
        // ctrl.searchBar.scopeButtonTitles = ["Tradeable", "Quoteable"]
        return ctrl
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.system.statusBarStyle
    }
    
    override var viewData: [EquitySymbol]? {
        didSet { persistViewData(with: API.questAuth.encoder) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = NSLocalizedString("Search", comment: "")
        self.title = title
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "search-outline"),
            selectedImage: UIImage(named: "search-fill")
        )
        tabBarItem.accessibilityIdentifier = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        view.addSubview(tableView)
        
        viewData = loadViewData(with: API.questAuth.decoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        themeDidUpdate(theme)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }

    
    // MARK: - DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Recently Viewed", comment: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell<EquitySymbol>
        cell.viewData = viewData?[indexPath.row]
        return cell
    }
    
    
    // MARK: - Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let symbolId = viewData?[indexPath.row].symbolId {
            presentSymbolCtrl(with: symbolId)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.viewData?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension SearchViewController: SearchResultsDelegate {
    func didSelect(symbol: EquitySymbol) {
        if viewData == nil {
            viewData = [EquitySymbol]()
        }
        
        if !viewData!.contains(symbol) {
            viewData?.append(symbol)
            tableView.reloadData()
        }
    }
}

extension SearchViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        tableView.setTheme(theme, with: nil)
        view.backgroundColor = theme.primaryBackgroundColor
    }
}
