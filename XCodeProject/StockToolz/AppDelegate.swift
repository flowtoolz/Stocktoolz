//
//  AppDelegate.swift
//  StockToolz
//
//  Created by Sebastian on 27/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Cocoa
import GetLaid
import SwiftyToolz

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
        mainView.addForAutoLayout(chartView)
        chartView >> mainView.allButBottom
        chartView.height >> mainView.height.at(0.75)
        chartView.timeRange = FocusedTimeRange.sharedInstance
        
        // load button
        let loadButton = mainView.addForAutoLayout(NSButton())
        loadButton.title = "Load"
        loadButton >> mainView.left.offset(10)
        loadButton >> mainView.bottom.offset(-10)
        loadButton.top >> chartView.bottom.offset(10)
        loadButton.width >> loadButton.height
        loadButton.action = #selector(AppDelegate.loadStockDataIntoViews)
        
        // run button
        let runButton = mainView.addForAutoLayout(NSButton())
        runButton.title = "Run"
        runButton.left >> loadButton.right.offset(10)
        runButton >> mainView.bottom.offset(-10)
        runButton.top >> chartView.bottom.offset(10)
        runButton.width >> runButton.height
        runButton.action = #selector(AppDelegate.runButtonClicked)
        
        // result view
        mainView.addForAutoLayout(resultView)
        resultView.left >> runButton.right.offset(10)
        resultView.top >> chartView.bottom.offset(10)
        resultView.isBezeled = false
        resultView.drawsBackground = false
        resultView.isEditable = false
        resultView.isSelectable = true
        resultView.preferredMaxLayoutWidth = 100
        // resultView.maximumNumberOfLines = 2
        
        // left buttons
        let leftButton = mainView.addForAutoLayout(NSButton())
        leftButton.title = "<"
        leftButton.left >> resultView.right.offset(10)
        leftButton >> mainView.bottom.offset(-10)
        leftButton.top >> chartView.bottom.offset(10)
        leftButton.width >> leftButton.height.at(0.5)
        leftButton.action = #selector(AppDelegate.leftButtonClicked)
        
        // zoom in/out buttons
        let zoomInButton = mainView.addForAutoLayout(NSButton())
        zoomInButton.title = "> <"
        zoomInButton.left >> leftButton.right
        zoomInButton.top >> chartView.bottom.offset(10)
        zoomInButton.width >> leftButton.height
        zoomInButton.action = #selector(AppDelegate.zoomInButtonClicked)
        
        let zoomOutButton = mainView.addForAutoLayout(NSButton())
        zoomOutButton.title = "<   >"
        zoomOutButton.left >> leftButton.right
        zoomOutButton >> mainView.bottom.offset(-10)
        zoomOutButton.top >> zoomInButton.bottom
        zoomOutButton >> zoomInButton.size
        zoomOutButton.action = #selector(AppDelegate.zoomOutButtonClicked)
        
        // right buttons
        let rightButton = mainView.addForAutoLayout(NSButton())
        rightButton.title = ">"
        rightButton.left >> zoomOutButton.right
        rightButton >> mainView.bottom.offset(-10)
        rightButton.top >> chartView.bottom.offset(10)
        rightButton >> mainView.right.offset(-10)
        rightButton.width >> leftButton.height.at(0.5)
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
        resultView.stringValue = "NOT IMPLEMENTED"
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



