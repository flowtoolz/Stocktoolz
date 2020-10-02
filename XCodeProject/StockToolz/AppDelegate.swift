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
    // MARK: App Life Cycle
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        createViews()
        
        getStockDayDataFromYahoo()
        
        loadStockDataIntoViews()
    }

    // MARK: Views
    
    func createViews()
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
        chartView.timeRange = FocusedTimeRange.sharedInstance
        
        // load button
        let loadButton = NSButton()
        loadButton.title = "Load"
        mainView.addSubview(loadButton)
        loadButton.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        loadButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        loadButton.autoPinEdge(.top, to: .bottom, of: chartView, withOffset: 10)
        loadButton.autoMatch(.width, to: .height, of: loadButton)
        loadButton.action = #selector(AppDelegate.loadStockDataIntoViews)
        
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
    
    // MARK: Interaction
    
    @objc func zoomInButtonClicked()
    {
        FocusedTimeRange.sharedInstance.zoomIn()
        
        chartView.redraw()
    }
    
    @objc func zoomOutButtonClicked()
    {
        FocusedTimeRange.sharedInstance.zoomOut()
        
        chartView.redraw()
    }
    
    @objc func rightButtonClicked()
    {
        FocusedTimeRange.sharedInstance.shiftToFuture()
        
        chartView.redraw()
    }
    
    @objc func leftButtonClicked()
    {
        FocusedTimeRange.sharedInstance.shiftToPast()
        
        chartView.redraw()
    }
    
    @objc func runButtonClicked()
    {
        resultView.stringValue = "calculating ..."
        
        let test = TraderPerformanceTest()
        
        test.run()
        
        resultView.stringValue = test.resultString
    }
    
    @objc func loadStockDataIntoViews()
    {
        StockExchangeDataInjector.reloadStockExchangeData()
        
        chartView.redraw()
    }
    
    func getStockDayDataFromYahoo()
    {
        YahooCSVCrawler().downloadAllHistoricStockData()
    }

    var chartView = ChartView()
    var resultView = NSTextField()
    
    @IBOutlet weak var window: NSWindow!
}



