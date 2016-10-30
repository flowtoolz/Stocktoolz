//
//  TradingTimeRange.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class TradingTimeRange
{
    convenience init()
    {
        self.init(firstTradingDayIndex: tradingDaysPerYear - 1, lastTradingDayIndex: 0)
    }
    
    init(firstTradingDayIndex firstDayIndex: Int, lastTradingDayIndex lastDayIndex: Int)
    {
        if firstDayIndex < lastDayIndex
        {
            print("error: firstTradingDayIndex < lastTradingDayIndex. this cannot be since indices go backwards in time. the newest data point is at zero.")
            
            return
        }
        
        firstTradingDayIndex = firstDayIndex
        lastTradingDayIndex = lastDayIndex
    }
    
    func numberOfDays() -> Int
    {
        return (firstTradingDayIndex - lastTradingDayIndex) + 1
    }
    
    var firstTradingDayIndex: Int = 0
    var lastTradingDayIndex: Int = 0
}
