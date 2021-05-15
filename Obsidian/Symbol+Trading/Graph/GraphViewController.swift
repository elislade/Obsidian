//
//  GraphViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-05-24.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class GraphViewController: ViewController<Int> {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var isHidden:Bool {
        get {
            return graphView.isHidden
        } set {
            segControl.isHidden = newValue
            graphView.isHidden = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: timerRefresh)
        
        graphView.layer.borderWidth = 0.5
        
        let rec = GraphGestureRecognizer(target: self, action: #selector(graph))
        graphView.addGestureRecognizer(rec)
        
        setUpSegControl()
        themeDidUpdate(theme)
        segControl.setTitleTextAttributes([NSAttributedString.Key(rawValue: "NSFont"): UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        
        timeLabel.isHidden = true
        feedbackLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeGraphViewTimeInterval(segControl)
        feedbackLabel.backgroundColor = view.tintColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    let graphTimeIntervals:[TimeInterval] = [.oneDay, .oneWeek, .oneMonth, .threeMonth, .sixMonth, .oneYear, .fiveYear]
    
    func setUpSegControl() {
        segControl.removeAllSegments()
        for i in graphTimeIntervals.enumerated() {
            segControl.insertSegment(withTitle: i.element.description(), at: i.offset, animated: false)
        }
        segControl.selectedSegmentIndex = 2
    }
    
    var selectedInterval:TimeInterval {
        let index = segControl.selectedSegmentIndex
        return graphTimeIntervals[index]
    }
    
    @IBAction func changeGraphViewTimeInterval(_ sender: UISegmentedControl) {
        if let id = viewData {
            let act = UIActivityIndicatorView(frame: graphView.bounds)
            act.style = .whiteLarge
            act.startAnimating()
            graphView.addSubview(act)
            self.fetchData(symbolId: id) {
                act.removeFromSuperview()
            }
        }
    }
    
    var timer:Timer!
    
    func timerRefresh(_ timer:Timer) {
        if let id = self.viewData {
            // Only timerRefresh for daily data
            if selectedInterval == .oneDay {
                self.fetchData(symbolId: id)
            }
        }
    }
    
    func fetchData(symbolId id:Int, comp:(() -> Void)? = nil) {
        let interval = selectedInterval
        let end = Date()
        var start = Date(timeInterval: -interval, since: end)
        
        if interval == .oneDay {
            start = Calendar.current.startOfDay(for: Date())
        }
        
        let r = CandleRequest(symbolID: id, dateInterval:DateInterval(start: start, end: end), interval: interval.granularity())
        API.quest.candles(req: r){ res in
            switch res {
            case .failure(_): break // print(error)
            case .success(let candelRes):
                DispatchQueue.main.async {
                    comp?()
                    self.graphView.timeInterval = interval
                    self.graphView.candles = candelRes.candles
                }
            }
        }
    }
    
    @objc func graph(rec:GraphGestureRecognizer) {
        
        func draw() {
            let points = rec.activeTouches.map { $0.location(in: view) }
            guard let minPoint = points.min(by: { a, b in a.x < b.x }) else {
                hideSelectedGraphViews()
                return
            }
            
            let same = points.max(by: { a, b in a.x < b.x }) == minPoint
            let maxPoint = !same ? points.max(by: { a, b in a.x < b.x }) : nil
            
            if let candles = selectCandles(minPoint: minPoint, maxPoint: maxPoint) {
                timeLabel.text = candles.start.end.format(as: .medium)
                if let endCandle = candles.end {
                    timeLabel.text = candles.start.end.formatInterval(toDate: endCandle.end, withStyle: .medium)
                }
            }
        }
        
        if rec.state == .began {
            draw()
        } else if rec.state == .changed {
            draw()
        } else {
            rec.activeTouches = []
            hideSelectedGraphViews()
        }
    }
    
    var candles:[Candle] {
        return graphView.candles
    }
    
    func selectCandles(minPoint: CGPoint, maxPoint: CGPoint?) -> (start:Candle, end:Candle?)? {
        
        if candles.count < 5 { return nil }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.timeLabel.isHidden = false
        }, completion: nil)
        
        segControl.isHidden = true
        feedbackLabel.isHidden = false
        
        let startIndex = graphView.index(closestTo: minPoint)
        let minCandle = candles[startIndex]
        let minValue = minCandle.close
        
        if let maxPoint = maxPoint {
            let endIndex = graphView.index(closestTo: maxPoint)
            let maxCandle = candles[endIndex]
            let maxValue = maxCandle.close
            
            let color = maxValue < minValue ? .red : view.tintColor!
            
            graphView.selectData(inRange: startIndex...endIndex, withColor: color)
            
            let change = (maxValue - minValue)
            let str = change.format(as: .currency)
            let str2 = (change / minValue).format(as: .percent)
            feedbackLabel.text = "\(str) (\(str2))"
            feedbackLabel.backgroundColor = color
            
            return (minCandle, maxCandle)
        } else {
            // single point
            
            graphView.selectData(inRange: startIndex...startIndex, withColor: view.tintColor!)
            feedbackLabel.text = minValue.format(as: .currency)
            feedbackLabel.backgroundColor = theme.secondaryForegroundColor
        }
        
        return (minCandle, nil)
    }
    
    func hideSelectedGraphViews() {
        graphView.selectedGraphLayer.sublayers?.removeAll()
        segControl.isHidden = false
        feedbackLabel.isHidden = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.timeLabel.isHidden = true
        }, completion: nil)
    }
}

extension GraphViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        timeLabel.textColor = theme.secondaryForegroundColor
        segControl.tintColor = theme.secondaryForegroundColor
    }
}
