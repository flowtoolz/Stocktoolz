//
//  ChartView.swift
//  StockToolz
//
//  Created by Sebastian on 29/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation
import Cocoa

class ChartView : NSView
{
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        
        // background
        NSColor.black.setFill()
        NSRectFill(dirtyRect)
    
        // get ticker
        let tickerArray = Array(StockExchange.sharedInstance.stockHistoriesByTicker.keys)
        numberOfStocks = tickerArray.count
        if numberOfStocks == 0 { return }
        tickerIndex %= numberOfStocks
        let ticker = tickerArray[tickerIndex]
        
        // draw ticker symbol as text text
        if let font = NSFont(name: "Helvetica Bold", size: 100.0)
        {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center
            
            let textFontAttributes = [NSFontAttributeName: font,
                                      NSParagraphStyleAttributeName: paragraphStyle,
                                      NSForegroundColorAttributeName: NSColor.init(white: 0.15, alpha: 1.0)]
            
            var tickerRect = dirtyRect
            tickerRect.size.height = (dirtyRect.size.height / 2.0) + 60.0
            ticker.draw(in: tickerRect, withAttributes: textFontAttributes)
        }
        
        // draw price history chart
        if let stockHistory = StockExchange.sharedInstance.stockHistoriesByTicker[ticker]
        {
            drawStockHistoryIntoRect(stockHistory: stockHistory, rect: dirtyRect)
        }
    }
    
    func drawStockHistoryIntoRect(stockHistory history: [StockDayData], rect: CGRect)
    {
        NSColor.white.setStroke()
        
        let path = NSBezierPath()
        
        let statistics = statisticsForStockHistory(stockHistory: history, tradingDayRange: timeRange)
        
        var firstDataPoint = true
        
        for dayIndex: Int in (timeRange.lastTradingDayIndex ... timeRange.firstTradingDayIndex).reversed()
        {
            if dayIndex >= history.count || dayIndex < 0
            {
                continue
            }

            let stockDayData = history[dayIndex]
            let day = timeRange.numberOfDays() - ((dayIndex - timeRange.lastTradingDayIndex) + 1)
            let relativeX = CGFloat(day) / CGFloat(timeRange.numberOfDays() - 1)
            
            // closing price
            let pixelX = relativeX * (rect.size.width - 1.0)
            //let valueRange = statistics.maximum - statistics.minimum
            //let pixelY = CGFloat((stockDayData.close - statistics.minimum) / valueRange) * rect.size.height
            let pixelY = CGFloat(stockDayData.close / statistics.maximum) * rect.size.height
            let point = CGPoint(x: CGFloat(pixelX), y: pixelY)
            
            if firstDataPoint
            {
                history[dayIndex].printLine()
                firstDataPoint = false
                path.move(to: point)
            }
            else
            {
                path.line(to: point)
            }
        }
        
        path.stroke()
    }
    
    func drawVolumeHistoryIntoRect(stockHistory history: [StockDayData], rect: CGRect)
    {
        NSColor.white.setStroke()
        
        let path = NSBezierPath()
        
        let statistics = statisticsForStockHistory(stockHistory: history, tradingDayRange: timeRange)
        
        var firstDataPoint = true
        
        for dayIndex: Int in (timeRange.lastTradingDayIndex ... timeRange.firstTradingDayIndex).reversed()
        {
            if dayIndex >= history.count || dayIndex < 0
            {
                continue
            }
            
            let stockDayData = history[dayIndex]
            let day = timeRange.numberOfDays() - ((dayIndex - timeRange.lastTradingDayIndex) + 1)
            let relativeX = CGFloat(day) / CGFloat(timeRange.numberOfDays() - 1)
            
            // closing price
            let pixelX = relativeX * (rect.size.width - 1.0)
            //let valueRange = statistics.maximum - statistics.minimum
            //let pixelY = CGFloat((stockDayData.close - statistics.minimum) / valueRange) * rect.size.height
            let pixelY = CGFloat(stockDayData.close / statistics.maximum) * rect.size.height
            let point = CGPoint(x: CGFloat(pixelX), y: pixelY)
            
            if firstDataPoint
            {
                history[dayIndex].printLine()
                firstDataPoint = false
                path.move(to: point)
            }
            else
            {
                path.line(to: point)
            }
        }
        
        path.stroke()
    }
    
    var tickerIndex = 0
    var numberOfStocks = 0
    var timeRange = TradingTimeRange()
    
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
        tickerIndex = tickerIndex % numberOfStocks
        
        redraw()
    }
    
    func redraw()
    {
        needsDisplay = true
    }
}
