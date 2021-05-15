//
//  OptionSelectTableViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-06-19.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

protocol OptionSelectDelegate {
    func didSelect(option:String, atIndex:IndexPath)
}

class OptionSelectTableViewController: UITableViewController {
    
    var options = [String]()
    var delegate:OptionSelectDelegate?
    var selectedIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        delegate?.didSelect(option: options[indexPath.row], atIndex: indexPath)
    }
}
