//
//  File.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

func statisticsForStockHistory(stockHistory history: [StockDayData],
                               tradingDayRange: TradingTimeRange) -> Statistics
{
    var statistics = Statistics()
    
    for i in tradingDayRange.lastTradingDayIndex ... tradingDayRange.firstTradingDayIndex
    {
        if i >= history.count || i < 0
        {
            continue
        }
        
        // closing price
        let close = history[i].close
        
        if close > statistics.maximum
        {
            statistics.maximum = close
        }
        else if statistics.minimum < 0.0 || close < statistics.minimum
        {
            statistics.minimum = close
        }
        
        // volume
        let volume = history[i].volume
        
        if volume > statistics.maxVolume
        {
            statistics.maxVolume = volume
        }
    }
    
    return statistics
}

struct Statistics
{
    var minimum: Double = -1.0
    var maximum: Double = 0.0
    
    var maxVolume: Int64 = 0
}
