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
        guard let mainView = window.contentView else
        {
            return
        }
        
        // chart view
        mainView.addSubview(chartView)
        chartView.autoPinEdgesToSuperviewEdges(with: NSEdgeInsetsZero, excludingEdge: .bottom)
        chartView.autoMatch(ALDimension.height,
                            to: ALDimension.height,
                            of: mainView,
                            withMultiplier: 0.75)
        
        // load button
        let loadButton = NSButton()
        loadButton.title = "Load"
        mainView.addSubview(loadButton)
        loadButton.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        loadButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        loadButton.autoPinEdge(.top, to: .bottom, of: chartView, withOffset: 10)
        loadButton.autoMatch(.width, to: .height, of: loadButton)
        loadButton.action = #selector(AppDelegate.loadDataButtonClicked)
        
        // run button
        let runButton = NSButton()
        runButton.title = "Run"
        mainView.addSubview(runButton)
        runButton.autoPinEdge(.left, to: .right, of: loadButton, withOffset: 10)
        runButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        runButton.autoPinEdge(.top, to: .bottom, of: chartView, withOffset: 10)
        runButton.autoMatch(.width, to: .height, of: runButton)
        runButton.action = #selector(AppDelegate.runButtonClicked)
        
        // result view
        mainView.addSubview(resultView)
        resultView.autoPinEdge(.left, to: .right, of: runButton, withOffset: 10)
        resultView.autoPinEdge(.top, to: .bottom, of: chartView, withOffset: 10)
        resultView.isBezeled = false
        resultView.drawsBackground = false
        resultView.isEditable = false
        resultView.isSelectable = true
        resultView.preferredMaxLayoutWidth = 100
        // resultView.maximumNumberOfLines = 2
        
        // left buttons
        let leftButton = NSButton()
        leftButton.title = "<"
        mainView.addSubview(leftButton)
        leftButton.autoPinEdge(.left, to: .right, of: resultView, withOffset: 10)
        leftButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        leftButton.autoPinEdge(.top, to: .bottom, of: chartView, withOffset: 10)
        leftButton.autoMatch(.width, to: .height, of: leftButton, withMultiplier: 0.5)
        leftButton.action = #selector(AppDelegate.leftButtonClicked)
        
        // zoom in/out buttons
        let zoomInButton = NSButton()
        zoomInButton.title = "> <"
        mainView.addSubview(zoomInButton)
        zoomInButton.autoPinEdge(.left, to: .right, of: leftButton)
        zoomInButton.autoPinEdge(.top, to: .bottom, of: chartView, withOffset: 10)
        zoomInButton.autoMatch(.width, to: .height, of: leftButton)
        zoomInButton.action = #selector(AppDelegate.zoomInButtonClicked)
        
        let zoomOutButton = NSButton()
        zoomOutButton.title = "<   >"
        mainView.addSubview(zoomOutButton)
        zoomOutButton.autoPinEdge(.left, to: .right, of: leftButton)
        zoomOutButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        zoomOutButton.autoPinEdge(.top, to: .bottom, of: zoomInButton)
        zoomOutButton.autoMatch(.width, to: .width, of: zoomInButton)
        zoomOutButton.autoMatch(.height, to: .height, of: zoomInButton)
        zoomOutButton.action = #selector(AppDelegate.zoomOutButtonClicked)
        
        // right buttons
        let rightButton = NSButton()
        rightButton.title = ">"
        mainView.addSubview(rightButton)
        rightButton.autoPinEdge(.left, to: .right, of: zoomInButton)
        rightButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        rightButton.autoPinEdge(.top, to: .bottom, of: chartView, withOffset: 10)
        rightButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
        rightButton.autoMatch(.width, to: .height, of: leftButton, withMultiplier: 0.5)
        rightButton.action = #selector(AppDelegate.rightButtonClicked)
    }
    
    func zoomInButtonClicked()
    {
        let exchange = StockExchange.sharedInstance
        let step = (exchange.focusRangeOldestDay - exchange.focusRangeLatestDay) / 20
        
        exchange.focusRangeLatestDay += step
        exchange.focusRangeOldestDay -= step
        
        chartView.redraw()
    }
    
    func zoomOutButtonClicked()
    {
        let exchange = StockExchange.sharedInstance
        let step = (exchange.focusRangeOldestDay - exchange.focusRangeLatestDay) / 20
        
        exchange.focusRangeLatestDay -= step
        exchange.focusRangeOldestDay += step
        
        chartView.redraw()
    }
    
    func rightButtonClicked()
    {
        let exchange = StockExchange.sharedInstance
        let step = (exchange.focusRangeOldestDay - exchange.focusRangeLatestDay) / 20
        
        exchange.focusRangeLatestDay -= step
        exchange.focusRangeOldestDay -= step
        
        chartView.redraw()
    }
    
    func leftButtonClicked()
    {
        let exchange = StockExchange.sharedInstance
        let step = (exchange.focusRangeOldestDay - exchange.focusRangeLatestDay) / 20
        
        exchange.focusRangeLatestDay += step
        exchange.focusRangeOldestDay += step
        
        chartView.redraw()
    }
    
    func runButtonClicked()
    {
        resultView.stringValue = "calculating ..."
        
        let test = TraderPerformanceTest()
        
        test.run()
        
        resultView.stringValue = test.resultString
    }
    
    func loadDataButtonClicked()
    {
        loadDataIntoDomainModel()
        
        chartView.redraw()
    }
    
    var chartView = ChartView()
    var resultView = NSTextField()
    
    func loadDataIntoDomainModel()
    {
        StockExchange.sharedInstance.stockHistoriesByTicker.removeAll()
        
        for stockGroupName in ["TecDAX"] //"DAX", , "MDAX", "SDAX"]
        {
            var stockHistoryGroup = StockHistoryGroup()
            
            stockHistoryGroup.name = stockGroupName
            stockHistoryGroup.stockHistoriesByTicker = YahooCSVParser().getStockHistoriesFromDirectory(stockGroupName)
            
            // for access by group/index
            StockExchange.sharedInstance.stockHistoryGroupsByName[stockGroupName] = stockHistoryGroup
            
            // for access by Ticker
            for (ticker, stockHistory) in stockHistoryGroup.stockHistoriesByTicker
            {
                StockExchange.sharedInstance.stockHistoriesByTicker[ticker] = stockHistory
            }
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



