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
        
        // data
        if let tecDax = StockExchange.sharedInstance.stockHistoryGroupsByName["TecDAX"]
        {
            // ticker
            let tickerArray = Array(tecDax.stockHistoriesByTicker.keys)
            numberOfStocks = tickerArray.count
            tickerIndex %= numberOfStocks
            let ticker = tickerArray[tickerIndex]
            
            // draw text
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
            
            if let stockHistory = tecDax.stockHistoriesByTicker[ticker]
            {
                drawStockHistoryIntoRect(stockHistory: stockHistory,
                                         rect: dirtyRect,
                                         oldestDayIndex: StockExchange.sharedInstance.focusRangeOldestDay,
                                         latestDayIndex: StockExchange.sharedInstance.focusRangeLatestDay)
            }
        }
    }
    
    func drawStockHistoryIntoRect(stockHistory history: [StockDayData], rect: CGRect,
                                  oldestDayIndex: Int,
                                  latestDayIndex: Int)
    {
        NSColor.white.setStroke()
        
        let path = NSBezierPath()
        
        let statistics = statisticsForStockHistory(stockHistory: history,
                                                   oldestDayIndex: oldestDayIndex,
                                                   latestDayindex: latestDayIndex)
        
        let numberOfDays = (oldestDayIndex - latestDayIndex) + 1
        var firstDataPoint = true
        
        for dayIndex: Int in (latestDayIndex ... oldestDayIndex).reversed()
        {
            if dayIndex >= history.count || dayIndex < 0
            {
                continue
            }

            let day = numberOfDays - ((dayIndex - latestDayIndex) + 1)
            
            let stockDayData = history[dayIndex]
            
            let relativeX = CGFloat(day) / CGFloat(numberOfDays - 1)
            let pixelX = relativeX * (rect.size.width - 1.0)
            
            let valueRange = statistics.maximum - statistics.minimum
            let pixelY = CGFloat((stockDayData.close - statistics.minimum) / valueRange) * rect.size.height
            
            let point = CGPoint(x: CGFloat(pixelX), y: pixelY)
            
            if firstDataPoint
            {
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
