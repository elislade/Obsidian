//
//  AccountTableViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-04.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class AccountTableViewController<RowData: Decodable>: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    typealias HeaderData = Account
    typealias Section = (HeaderData, [RowData])
    
    
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: view.bounds)
        tb.dataSource = self
        tb.delegate = self
        tb.backgroundColor = .clear
        tb.tableFooterView = UIView()
        tb.refreshControl = UIRefreshControl()
        tb.refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        tb.register(TableViewHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        return tb
    }()
    
    var viewData: [Section]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private var hiddenSections = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        themeDidUpdate(theme)
    }
    
    func getData(for account: Account, completion: @escaping APIRes<[RowData]>) {
        fatalError("Get Data needs to be overriden in subclass.")
    }
    
    @objc private func fetchData() {
        if let acts = User.shared?.accounts {
            var tempData = [Section]()
            for act in acts {
                getData(for: act){ res in
                    switch res {
                    case .failure(_): self.viewData = []
                    case .success(let data):
                        tempData.append((act, data))
                        if tempData.count == acts.count {
                            tempData.sort(by: { $0.0.type.rawValue < $1.0.type.rawValue })
                            self.viewData = tempData
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewData == nil {
            tableView.refreshControl?.beginRefreshing()
        }
        fetchData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func cellEvent(name: String, cellData: RowData?) {
        // NOTE: Override in subclass
    }
    
    //MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewData?[section].1.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let shouldHide = hiddenSections.contains(indexPath.section)
        return shouldHide ? 0 : tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell<RowData>
        cell.viewData = viewData?[indexPath.section].1[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    
    //MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! TableViewHeader
        header.section = section
        header.delegate = self
        header.viewData = viewData?[section].0
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! TableViewHeader
        header.isHighlighted = !hiddenSections.contains(section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
}

extension AccountTableViewController: TableViewCellDelegate {
    func eventOccured(name: String, cellData: Any?) {
        cellEvent(name: name, cellData: cellData as? RowData)
    }
}

extension AccountTableViewController: TableViewHeaderDelegate {
    func tap(view: UITableViewHeaderFooterView, section: Int) {
        if let index = hiddenSections.firstIndex(of: section) {
            hiddenSections.remove(at: index)
        } else {
            hiddenSections.append(section)
        }
        
        tableView.performBatchUpdates(nil, completion: nil)
    }
}

extension AccountTableViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        tableView.setTheme(theme, with: nil)
        view.backgroundColor = theme.primaryBackgroundColor
    }
}
