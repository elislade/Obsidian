//
//  TradingOptionsTableViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-06-18.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

protocol TradingOrderDelegate {
    func didUpdate(order:PostOrderRequest, validity:Bool)
}

class TradingOptionsTableViewController: UITableViewController {
    
    var postOrder:PostOrderRequest?
    var tradingDelegate:TradingOrderDelegate?
    
    @IBOutlet weak var quantityCell: UITableViewCell!
    @IBOutlet weak var limitPriceCell: UITableViewCell!
    @IBOutlet weak var accountCell: UITableViewCell!
    @IBOutlet weak var durationCell: UITableViewCell!
    @IBOutlet weak var orderTypeCell: UITableViewCell!
    
    var optionCells = [(cell:UITableViewCell, options:[String])]()
    
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityTextInput: UITextField!
    
    @IBAction func stepQuantity(_ sender: UIStepper) {
        quantityTextInput.text = "\(sender.value)"
        postOrder?.qunantity = Int(sender.value)
        checkOrderRquirements()
    }
    
    var lastSelectedCell:String?
    
    let options:[String:[String]] = [
        "orderType": OrderType.allCases.map{ $0.rawValue },
        "duration": OrderTimeInForce.allCases.map{ $0.rawValue },
        "account": (User.shared?.accounts.map{ $0.type.rawValue + "-" + $0.number })!
    ]
    
    func configureCells(for orderType:OrderType) -> [UITableViewCell] {
        var cells:[UITableViewCell] = [
            accountCell, quantityCell, orderTypeCell, durationCell
        ]
        
        if orderType == .Limit {
            cells.insert(limitPriceCell, at: 2)
        }
        
        return cells
    }
    
    let acts = User.shared?.accounts.map{ $0.type.rawValue + "-" + $0.number }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let acts = User.shared?.accounts.map{ $0.type.rawValue + "-" + $0.number }
        
        optionCells.append((accountCell, acts!))
        optionCells.append((durationCell, ["Day"]))
        optionCells.append((orderTypeCell, ["Limit"]))
        
        view.layer.cornerRadius = 8
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "OptionSelect") as? OptionSelectTableViewController {
            optionsTableViewController = vc
            vc.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let info = postOrder {
            quantityTextInput.text = "\(info.qunantity)"
            accountCell.detailTextLabel?.text = info.accountNumber
            orderTypeCell.detailTextLabel?.text = info.orderType.rawValue
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var optionsTableViewController:OptionSelectTableViewController!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        if optionCells.contains(where: {$0.cell == selectedCell}) {
            optionsTableViewController.title =  selectedCell?.textLabel?.text
            
            lastSelectedCell = nil
            
            if selectedCell == orderTypeCell {
                lastSelectedCell = "orderType"
                optionsTableViewController.options = options["orderType"]!
            } else if selectedCell == durationCell {
                lastSelectedCell = "duration"
                optionsTableViewController.options = options["duration"]!
            } else if selectedCell == accountCell {
                lastSelectedCell = "account"
                optionsTableViewController.options = options["account"]!
            }
            
            parent?.navigationController?.pushViewController(optionsTableViewController, animated: true)
        }
    }
    
    func checkOrderRquirements() {
        guard let order = postOrder else { return }
        
        let number = order.accountNumber != ""
        //let orderType = order.orderType != nil
        let quant = order.qunantity > 0
        
        let valid = number && quant ? true : false
        
        tradingDelegate?.didUpdate(order: order, validity: valid)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedCell = tableView.cellForRow(at: indexPath)
        if optionCells.contains(where: {$0.cell == selectedCell}) {
            return indexPath
        }
        return nil
    }
    
}

extension TradingOptionsTableViewController: OptionSelectDelegate {
    func didSelect(option: String, atIndex: IndexPath) {
        parent?.navigationController?.popViewController(animated: true)
        
        if let last = lastSelectedCell {
            if last == "duration" {
                postOrder?.timeInForce = OrderTimeInForce(rawValue: option)!
            }
            
            if last == "orderType" {
                postOrder?.orderType = OrderType(rawValue: option)!
            }
            
            if last == "account" {
                postOrder?.accountNumber = User.shared!.accounts[atIndex.row].number
            }
        }
        
        checkOrderRquirements()
    }
}
