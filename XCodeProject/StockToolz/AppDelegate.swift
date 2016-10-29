//
//  AppDelegate.swift
//  StockToolz
//
//  Created by Sebastian on 27/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Cocoa
import PureLayout

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate
{
    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        //runStockToolz()

        guard let mainView = window.contentView else
        {
            return
        }
        
        // chart view
        let chartView = ChartView()
        mainView.addSubview(chartView)
        chartView.autoPinEdgesToSuperviewEdges(with: NSEdgeInsetsZero, excludingEdge: .bottom)
        chartView.autoMatch(ALDimension.height,
                            to: ALDimension.height,
                            of: mainView,
                            withMultiplier: 0.75)
        
        // button
        let button = NSButton()
        button.title = "Run"
        mainView.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .left)
        button.autoPinEdge(toSuperviewEdge: .bottom)
        button.autoPinEdge(.top, to: .bottom, of: chartView)
        button.autoMatch(.width, to: .height, of: button)
    }
    
    func runStockToolz()
    {
        loadDataIntoDomainModel()
        
        //DomainModel.sharedInstance.run()
    }
    
    func loadDataIntoDomainModel()
    {
        let model = DomainModel.sharedInstance
        
        for stockGroupName in ["TecDAX"] //"DAX", , "MDAX", "SDAX"]
        {
            var stockHistoryGroup = StockHistoryGroup()
            
            stockHistoryGroup.name = stockGroupName
            stockHistoryGroup.stockHistoriesByTicker = YahooCSVParser().getStockHistoriesFromDirectory(stockGroupName)
            
            model.stockHistoryGroupsByName[stockGroupName] = stockHistoryGroup
        }
    }
    
    func getStockDayDataFromYahoo()
    {
        let crawler = YahooCSVCrawler()
        
        crawler.saveHistoricStockDataForTickerListInDirectory("DAX")
        crawler.saveHistoricStockDataForTickerListInDirectory("TecDAX")
        crawler.saveHistoricStockDataForTickerListInDirectory("MDAX")
        crawler.saveHistoricStockDataForTickerListInDirectory("SDAX")
    }
}

class ChartView : NSView
{
    override func draw(_ dirtyRect: NSRect)
    {
        // background
        NSColor.black.setFill()
        NSRectFill(dirtyRect)
        
        // data
        let model = DomainModel.sharedInstance
        
        if let tecDax = model.stockHistoryGroupsByName["TecDAX"]
        {
            // ticker
            let tickerArray = Array(tecDax.stockHistoriesByTicker.keys)
            let ticker = tickerArray[tickerIndex]
        
            // draw text
            if let font = NSFont(name: "Helvetica Bold", size: 100.0)
            {
                let textFontAttributes = [NSFontAttributeName: font,
                                          NSForegroundColorAttributeName: NSColor.darkGray]
                
                ticker.draw(at: NSPoint(x: 10.0, y: dirtyRect.size.height - 110.0),
                            withAttributes: textFontAttributes)
            }
            
            if let stockHistory = tecDax.stockHistoriesByTicker[ticker]
            {
                drawStockHistoryIntoRect(stockHistory: stockHistory, rect: dirtyRect)
            }
        }
        
        super.draw(dirtyRect)
    }
    
    func drawStockHistoryIntoRect(stockHistory history: [StockDayData], rect: CGRect)
    {
        let maxPrice = getMaxValueFromStockHistory(stockHistory: history)
        
        NSColor.white.setStroke()
        
        let path = NSBezierPath()
        
        let numOfChartPoints = Int(rect.size.width)
        
        for chartPoint in 0..<numOfChartPoints
        {
            let relativeX = CGFloat(chartPoint) / CGFloat(numOfChartPoints - 1)
            let pixelX = relativeX * rect.size.width - 1
            
            let numberOfDays = min(history.count, 262)
            let firstIndex = numberOfDays - 1
            
            let dataIndex = firstIndex - Int(relativeX * CGFloat(numberOfDays - 1))
            
            if dataIndex >= history.count
            {
                return
            }
            
            let stockDayData = history[dataIndex]
            
            let pixelY = CGFloat(stockDayData.close / maxPrice) * rect.size.height
            
            if chartPoint == 0
            {
                path.move(to: CGPoint(x: pixelX, y: pixelY))
            }
            else
            {
                path.line(to: CGPoint(x: pixelX, y: pixelY))
            }
        }
        
        path.stroke()
    }
    
    func getMaxValueFromStockHistory(stockHistory history: [StockDayData]) -> Double
    {
        var max = 0.0
        
        for stockDayData in history
        {
            if stockDayData.close > max
            {
                max = stockDayData.close
            }
        }
        
        return max
    }
    
    override var acceptsFirstResponder: Bool
    {
        get
        {
            return true
        }
    }
    
    override func mouseDown(with event: NSEvent)
    {
        tickerIndex += 1
        tickerIndex = tickerIndex % 30
        setNeedsDisplay(self.frame)
    }
    
    var tickerIndex = 0
}

