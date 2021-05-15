//
//  SymbolViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-08-31.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class SymbolViewController: ViewController<Int> {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var askPriceLabel: Label!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var bidPriceLabel: Label!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var tradeButton: UIButton!
    
    let symbolView = SymbolView.fromNib()
    
    @IBOutlet weak var toggleInfoButton: UIBarButtonItem!
    
    @IBAction func toggleInfo(_ sender: Any) {
        let i = UIImage(named:"Info")
        let iS = UIImage(named:"Info-selected")
        toggleInfoButton.image = isSymbolInfoVisible ? i : iS
        
        isSymbolInfoVisible = !isSymbolInfoVisible
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
            self.symbolView.isHidden = !self.isSymbolInfoVisible
        }, completion: nil)
    }
    
    var graphViewCtrl:GraphViewController!
    
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trade(_ sender: Any) { }
    
    var isSymbolInfoVisible = false
    var timer:Timer!
    
    func timerRefresh(_ timer:Timer) {
        if let id = self.viewData {
            self.fetchQuote(for: id)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: timerRefresh)
        if let graphCtrl = storyboard?.initVC(GraphViewController.self) {
            graphViewCtrl = graphCtrl
            addChild(graphCtrl)
            mainStackView.insertArrangedSubview(graphCtrl.view, at: 1)
            graphCtrl.didMove(toParent: self)
        }
        
        mainStackView.insertArrangedSubview(symbolView, at: 1)
        symbolView.isHidden = true
        
        let f = view.readableContentGuide.layoutFrame
        preferredContentSize = f.size
        
        askPriceLabel.textInset = UIEdgeInsets.init(top: 2, left: 5, bottom: 2, right: 5)
        bidPriceLabel.textInset = UIEdgeInsets.init(top: 2, left: 5, bottom: 2, right: 5)
        
        tradeButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var size = mainStackView.frame.size
        
        if let top = view.constraints.filter({ $0.firstAttribute == .top }).first {
            size.height += top.constant * 2
        }

        size.height += view.safeAreaInsets.bottom
        preferredContentSize = size
        navigationController?.preferredContentSize = preferredContentSize
    }
    
    var quote:Quote?
    var equitySymbol:EquitySymbol?
    var symbol:Symbol?
    
    func renderViewData() {
        if let q = quote {
            DispatchQueue.main.async {
                self.symbolLabel.text = q.symbol
                self.priceLabel.text = q.lastTradePrice?.format(as: .currency)
                let ask = NSLocalizedString("Ask", comment: "") + " "
                let bid = NSLocalizedString("Bid", comment: "") + " "
                self.askPriceLabel.text = ask.append(string: q.askPrice?.format(as: .currency))
                self.bidPriceLabel.text = bid.append(string: q.bidPrice?.format(as: .currency))
            }
        }
        
        if let prevDayClose = symbol?.prevDayClosePrice, let q = quote {
            DispatchQueue.main.async {
                self.changeLabel.text = "--"
                if let last = q.lastTradePrice {
                    if prevDayClose != 0 {
                        let change = last - prevDayClose
                        let percent = change / prevDayClose
                        self.changeLabel.text = "\(change.format(as: .currency){$0.positivePrefix = "+"}) (\(percent.format(as: .percent)))"
                        self.changeLabel.textColor = change > 0 ? self.view.tintColor : change < 0 ? .red : .gray
                    }
                }
            }
        }
        
        if let s = symbol {
            DispatchQueue.main.async {
                self.symbolView.viewData = s
                self.symbolView.renderViewData()
                self.currencyLabel.text = s.currency
            }
        }
        
        if let es = equitySymbol {
            DispatchQueue.main.async {
                self.descriptionLabel.text = es.description
                if es.isTradable {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                        self.tradeButton.isHidden = false
                    }, completion: nil)
                }
            }
        }
    }
    
    func fetchQuote(for symbolId:Int) {
        API.quest.quotes(for: symbolId){ res in
            switch res {
            case .failure(_): break
            case .success(let quoteResponse):
                self.quote = quoteResponse.quotes.first
                self.renderViewData()
            }
        }
    }
    
    func fetchData(for symbolId:Int) {
        API.quest.symbols(for: symbolId) { res in
            switch res {
            case .failure(_): break
            case .success(let symbolResponse):
                self.symbol = symbolResponse.symbols.first
                self.renderViewData()
                
                let s = self.symbol!.symbol
                API.quest.search(req: SearchRequest(prefix: s, offset: 0)) { res in
                    switch res {
                        case .failure(_): break
                        case .success(let symbolResponse):
                            self.equitySymbol = symbolResponse.symbols.first
                            self.renderViewData()
                    }
                }
            }
        }
        
        fetchQuote(for: symbolId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        themeDidUpdate(theme)
        // causing memory leak !!!!
        // ThemeManager.main.drawTheme(from: self)
        
        if let symbolId = viewData {
            fetchData(for: symbolId)
            graphViewCtrl.viewData = symbolId
        }
    }
}

extension SymbolViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        view.backgroundColor = theme.secondaryBackgroundColor
        symbolView.themeDidUpdate(theme)
        
        tradeButton.backgroundColor = theme.primaryBackgroundColor
        symbolLabel.textColor = theme.primaryForegroundColor
        priceLabel.textColor = theme.secondaryForegroundColor
        
        descriptionLabel.textColor = theme.secondaryForegroundColor

        askPriceLabel.textColor = theme.secondaryForegroundColor
        askPriceLabel.backgroundColor = theme.primaryBackgroundColor
        
        bidPriceLabel.textColor = theme.secondaryForegroundColor
        bidPriceLabel.backgroundColor = theme.primaryBackgroundColor
        
        currencyLabel.textColor = theme.secondaryForegroundColor
    }
}
