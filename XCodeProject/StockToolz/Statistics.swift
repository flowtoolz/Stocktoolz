//
//  File.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

func statisticsForStockHistory(stockHistory history: [StockDayData],
                               oldestDayIndex: Int,
                               latestDayindex: Int) -> Statistics
{
    var statistics = Statistics()
    
    for i in latestDayindex ... oldestDayIndex
    {
        if i >= history.count || i < 0
        {
            continue
        }
        
        let close = history[i].close
        
        if close > statistics.maximum
        {
            statistics.maximum = close
        }
        else if statistics.minimum < 0.0 || close < statistics.minimum
        {
            statistics.minimum = close
        }
    }
    
    return statistics
}

struct Statistics
{
    var minimum: Double = -1.0
    var maximum: Double = 0.0
}
