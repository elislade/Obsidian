//
//  GraphView.swift
//  Stocks
//
//  Created by Eli Slade on 2018-03-13.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

protocol GraphViewDelegate {
    func graphView(_ graphView:GraphView, selectionCenterPoint point:CGPoint)
}

class GraphView: UIView {
    
    
    //MARK: - Header Variables
    
    typealias AxisLabelData = (strings: [String], alignmentMode: String)
    
    // var xAxisLabel: AxisLabelData = (["No Label Data"], "center")
    var yAxisLabel: AxisLabelData = (["No Label Data"], "right")
    
    var maxClose:Double = 0
    var minClose:Double = 0
    var maxVolume:Int = 0
    var minVolume:Int = 0
    
    var graphLayer = CALayer()
    var selectedGraphLayer = CALayer()
    var feebackLable = CATextLayer()
    
    var isFullscreen = false
    
    var delegate:GraphViewDelegate?
    
    func strings(from component:Calendar.Component) -> [String]? {
        switch component {
        case .month: return Calendar.current.shortMonthSymbols
        case .weekday: return Calendar.current.shortWeekdaySymbols
        default: return nil
        }
    }
    
    var candles = [Candle]() {
        didSet {
            if candles.count > 5 {
                feebackLable.opacity = 0
                
                maxClose = candles.max { $0.close < $1.close }!.close
                minClose = candles.min { $0.close < $1.close}!.close
                maxVolume = candles.max { $0.volume < $1.volume }!.volume
                minVolume = candles.min { $0.volume < $1.volume }!.volume
                calculatePoints()
            } else {
                feebackLable.opacity = 1
            }
        }
    }
    
    var timeInterval: TimeInterval = .oneMonth
    
    struct XLabelViewData {
        let range:Range<Int>
        let value:String
        let alignment:String
    }
    
    func makeXAxisData() -> [XLabelViewData] {
        var data = [XLabelViewData]()
        
        // 1. generate ranges in data
        let ranges = makeXDataRanges()
        
        for i in ranges.enumerated() {
            let range = i.element.range
            let comp = timeInterval.calComponent()
            let c = Calendar.current.component(comp, from: i.element.candle.end)
            var value = "\(c)"
            if let s = strings(from: comp) {
                value = s[c-1]
            }
            let alignment = "left"
            data.append(XLabelViewData(range:range, value: value, alignment: alignment))
        }
        return data
    }
    
    
    func makeXDataRanges() -> [(range:Range<Int>, candle: Candle)] {
        var ranges = [(Range<Int>, Candle)]()
        
        var lastStartIndex = 0
        var lastCandle = candles.first!
        
        for i in candles.enumerated() {
            let s = timeInterval.subPattern()
            let lastComp = Calendar.current.component(s.comp, from: lastCandle.end)
            let currentComp = Calendar.current.component(s.comp, from: i.element.end)
            
            if currentComp >= lastComp + s.change || lastComp > currentComp {
                ranges.append((lastStartIndex..<i.offset, candles[lastStartIndex]))
                lastStartIndex = i.offset
                lastCandle = i.element
            }
        }
        ranges.append((lastStartIndex..<candles.count, candles[lastStartIndex]))
        return ranges
    }
    
    
    //MARK: - Private Vars
    
    private var hapticFeedback = UISelectionFeedbackGenerator()
    private var prevIndex = 0
    private var prevRange = 0...0
    private let labelHeight:CGFloat = 16
    private var graphRect = CGRect.zero
    private var volumeBarsRect = CGRect.zero
    private var points = [CGPoint]()
    
    
    //MARK: - Private Methods
    
    private func calculatePoints() {
        points = []
        let closeDiff = maxClose - minClose
        let yscale = graphRect.height / CGFloat(closeDiff)
        let xScale = graphRect.width / CGFloat(candles.count - 1)
        
        for (index, candle) in candles.enumerated() {
            //let y = CGFloat(candle.closeOrLow - minClose) * yscale
            let y:CGFloat = CGFloat(candle.close - minClose) * yscale
            let x = CGFloat(index) * xScale
            points.append(CGPoint(x: x, y: graphRect.height - y))
        }
    }
    
    private func makeLabel(string: String) -> CATextLayer {
        let label = CATextLayer()
        label.string = string
        label.contentsScale = UIScreen.main.traitCollection.displayScale
        label.fontSize = 14
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.frame = CGRect(x: 0, y: 0, width: 60, height: labelHeight)
        label.foregroundColor = isFullscreen ? theme.primaryForegroundColor.cgColor : UIColor(red:0.44, green:0.46, blue:0.45, alpha:1.00).cgColor
        return label
    }
    
    private func makePath(from points:[CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            }
            path.addLine(to: point)
        }
        return path
    }
    
    private func makeGraph(frame: CGRect, colors: (UIColor, UIColor), range: CountableClosedRange<Int>, lineWidth:CGFloat = 1) -> CALayer {
        
        let localPoints = Array(points[range])
        let path = makePath(from: localPoints)
        
        let line = CAShapeLayer()
        line.frame = frame
        line.strokeColor = colors.0.withAlphaComponent(1).cgColor
        line.lineWidth = lineWidth
        line.lineJoin = convertToCAShapeLayerLineJoin("round")
        line.path = path.cgPath
        line.fillColor = nil
        
        let fill = CAGradientLayer()
        fill.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height + 16)
        fill.colors = [
            colors.0.cgColor,
            colors.1.cgColor
        ]
        
        let layerMask = CAShapeLayer()
        if let firstPoint = localPoints.first, let lastPoint = localPoints.last {
            path.addLine(to: CGPoint(x: lastPoint.x, y: fill.frame.height))
            path.addLine(to: CGPoint(x: firstPoint.x, y: fill.frame.height))
        }
        path.close()
        layerMask.path = path.cgPath
        fill.mask = layerMask
        
        let graph = CALayer()
        graph.addSublayer(fill)
        graph.addSublayer(line)
        return graph
    }
    
    private func makeVolumeBars(frame:CGRect, with color:UIColor = .white, range: CountableClosedRange<Int>) -> CALayer {
        let bars = CALayer()
        bars.frame = frame
        
        let width:CGFloat = 2
        
        let xScale = (frame.width - width) / CGFloat(candles.count - 1)
        
        let volumeDiff = maxVolume - minVolume
        
        // Prevents dividing by zero which causes CALayerInvalidGeometry
        if volumeDiff == 0 {
            return bars
        }
        
        let volumeScale = (frame.height - 3) / CGFloat(volumeDiff)
        
        for index in range {
            let candle = candles[index]
            let index = CGFloat(index)
            
            let barLayer = CALayer()
            let height = CGFloat(candle.volume - minVolume) * volumeScale
            let x = index * xScale
            let y = frame.height - height
            
            barLayer.frame = CGRect(x: x, y: y, width: width, height: height)
            barLayer.backgroundColor = color.cgColor
            
            bars.addSublayer(barLayer)
        }
        
        return bars
    }
    
    private func makeYaxis(frame: CGRect) -> CALayer {
        let layer = CALayer()
        layer.frame = frame
        
        let line = CAShapeLayer()
        line.frame = CGRect(x: frame.width - self.frame.width, y: 0, width: self.frame.width, height: frame.height)
        
        let path = UIBezierPath()
        
        let changeClose = maxClose - minClose
        let numberOfLabels = isFullscreen ? 5 : 2
        
        let segPixelChange = (frame.height - labelHeight) / CGFloat(numberOfLabels - 1)
        let valueChangePerPixel:CGFloat = CGFloat(changeClose) / (frame.height - labelHeight)
        let segValueChange = segPixelChange * valueChangePerPixel
        
        for index in 0..<numberOfLabels {
            let v = CGFloat(maxClose) - (CGFloat(index) * segValueChange)
            let y = CGFloat(index) * segPixelChange
            
            let label = makeLabel(string: Double(v).format(as: .currency))
            label.alignmentMode = convertToCATextLayerAlignmentMode(yAxisLabel.alignmentMode)
            label.frame.origin.x = 0
            label.frame.origin.y = y
            label.frame.size.width = frame.width
            layer.addSublayer(label)

            path.move(to: CGPoint(x: 0, y: y ))
            path.addLine(to: CGPoint(x:self.frame.width, y: y ))
        }
        
        if isFullscreen {
            line.lineWidth = 1
            line.path = path.cgPath
            line.lineDashPattern = [1,2]
            line.lineCap = convertToCAShapeLayerLineCap("round")
            line.strokeColor = theme.primaryForegroundColor.withAlphaComponent(0.2).cgColor
            layer.addSublayer(line)
        }
        return layer
    }
    
    private func makeXaxis(frame: CGRect) -> CALayer {
        let layer = CALayer()
        
        let step = frame.width / CGFloat(candles.count - 1)
        
        let line = CAShapeLayer()
        line.frame = frame
        
        let path = UIBezierPath()
        
        for data in makeXAxisData() {
            let x = CGFloat(data.range.lowerBound) * step
            let label = makeLabel(string: data.value)
            let width = (CGFloat(data.range.count) * step) - 1
            label.frame.size.width = width
            label.alignmentMode = convertToCATextLayerAlignmentMode(data.alignment)
            label.frame.origin.y = frame.height - label.frame.height
            label.frame.origin.x = x
            layer.addSublayer(label)
            path.move(to: CGPoint(x: x + width + 1, y: 0 ))
            path.addLine(to: CGPoint(x: x + width + 1, y: frame.height))
        }
        
        line.lineWidth = 1
        line.path = path.cgPath
        line.lineCap = convertToCAShapeLayerLineCap("round")
        line.strokeColor = theme.primaryForegroundColor.withAlphaComponent(0.15).cgColor
        layer.addSublayer(line)
        
        return layer
    }
    
    private func makeBaseLine(y: CGFloat) -> CALayer {
        let baseLine = CALayer()
        baseLine.frame = CGRect(x: 0, y: y, width: frame.width, height: 0.5)
        baseLine.backgroundColor = isFullscreen ? theme.primaryForegroundColor.cgColor : theme.primaryForegroundColor.withAlphaComponent(0.6).cgColor
        return baseLine
    }
    
    private func makeLayers() -> CALayer {
        let layer = CALayer()
        layer.frame = self.bounds
        
        // calculate all the different layer frames
        let volumeHeight:CGFloat = 20
        var yAxisTop:CGFloat = 0
        var yAxisHeight:CGFloat = frame.height - volumeHeight - labelHeight
        let yAxisWidth:CGFloat = 42
        var graphInsets = UIEdgeInsets(top:  labelHeight, left: 0, bottom:  labelHeight + volumeHeight + labelHeight, right: 0)
        
        if isFullscreen {
            graphInsets.right = yAxisWidth
            yAxisTop = labelHeight
            yAxisHeight -= labelHeight
        }
        
        graphRect = bounds.inset(by: graphInsets)
        calculatePoints()
        volumeBarsRect = CGRect(x: 0, y: bounds.height - volumeHeight, width: graphRect.width, height: volumeHeight)
        let yAxisRect = CGRect(x: bounds.width - yAxisWidth, y: yAxisTop, width: yAxisWidth, height: yAxisHeight)
        let xAxisRect = CGRect(x: 0, y: 0, width: graphRect.width, height: bounds.height - volumeHeight)
        
        
        let c = theme.primaryForegroundColor
        let colors = (c.withAlphaComponent(0.2), c.withAlphaComponent(0.02))
        
        // make all the layers based on calculated frames
        layer.addSublayer( makeGraph(frame: graphRect, colors: colors, range: 0...candles.count - 1) )
        layer.addSublayer(
            makeVolumeBars(
                frame: volumeBarsRect,
                with: ThemeManager.main.theme.secondaryForegroundColor,
                range: 0...candles.count - 1
            )
        )
        layer.addSublayer( makeBaseLine(y: 0) )
        layer.addSublayer( makeBaseLine(y: graphRect.height + (labelHeight * 2)) )
        layer.addSublayer( makeYaxis(frame: yAxisRect) )
        layer.addSublayer( makeXaxis(frame: xAxisRect) )
        return layer
    }
    
    private func makeCursor(forIndex index:Int, withColor color:UIColor) -> CALayer {
        if points.count < index { return CALayer() }
        let point = points[index]
        
        let line = CALayer()
        line.frame = CGRect(x: point.x, y: 0, width: 1, height: graphRect.height + (labelHeight * 2))
        line.backgroundColor = color.cgColor
        let dot = CALayer()
        dot.cornerRadius = 5
        dot.frame = CGRect(x: -4.5, y: (point.y + labelHeight) - 5, width: 10, height: 10)
        dot.backgroundColor = color.cgColor
        line.addSublayer(dot)
        return line
    }
    
    
    //MARK: - Public Methods
    
    func index(closestTo point: CGPoint) -> Int {
        let step = (graphRect.width + 15) / CGFloat(candles.count)
        let absolutePoint = point //convert(point, from: nil)
        
        var index = Int(ceil(absolutePoint.x / step))
        let minIndex = 0
        let maxIndex = points.count - 1
        
        if index < minIndex { index = minIndex }
        if index > maxIndex { index = maxIndex }
        
        return index
    }
    
    func selectData(inRange range: CountableClosedRange<Int>, withColor color: UIColor = .white) {
        hapticFeedback.prepare()
        if range != prevRange {
            hapticFeedback.selectionChanged()
            prevRange = range
        }
        
        selectedGraphLayer.sublayers?.removeAll()
        if range.count > 1 {
            let colors = (color.withAlphaComponent(0.2), color.withAlphaComponent(0.7))
            selectedGraphLayer.addSublayer(makeGraph(frame: graphRect, colors: colors, range: range, lineWidth: 2))
            selectedGraphLayer.addSublayer(makeCursor(forIndex: range.lowerBound, withColor: color))
        }
        selectedGraphLayer.addSublayer(makeCursor(forIndex: range.upperBound, withColor: color))
        selectedGraphLayer.addSublayer(makeVolumeBars(frame: volumeBarsRect, with: color, range: range))
    }
    
    
    //MARK: - Required init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        feebackLable = makeLabel(string: "No Graph Data")
        feebackLable.alignmentMode = convertToCATextLayerAlignmentMode("center")
        feebackLable.opacity = 0
        
        backgroundColor = theme.primaryBackgroundColor.withAlphaComponent(0.3)
        layer.addSublayer(graphLayer)
        layer.addSublayer(selectedGraphLayer)
        layer.addSublayer(feebackLable)
    }
    
    
    //MARK: - Override Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        graphLayer.frame = bounds
        graphLayer.sublayers?.removeAll()
        
        feebackLable.frame.size.width = bounds.width
        feebackLable.frame.origin.y = (bounds.height - feebackLable.frame.height) / 2
        
        if candles.count > 5 {
            graphLayer.addSublayer(makeLayers())
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        graphLayer.frame = frame
        layer.addSublayer(graphLayer)
    }
    
}

extension GraphView: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        graphLayer.sublayers?.removeAll()
        if candles.count > 5 {
            graphLayer.addSublayer(makeLayers())
        }
        backgroundColor = theme.primaryBackgroundColor.withAlphaComponent(0.3)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineJoin(_ input: String) -> CAShapeLayerLineJoin {
	return CAShapeLayerLineJoin(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATextLayerAlignmentMode(_ input: String) -> CATextLayerAlignmentMode {
	return CATextLayerAlignmentMode(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
	return CAShapeLayerLineCap(rawValue: input)
}
