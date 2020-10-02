//
//  trader.swift
//  StockToolz
//
//  Created by Sebastian on 29/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class Trader
{
    func trade(onTradingDayIndex dayIndex: Int, depot: Depot) -> Bool
    {
        // ensure we have all required data
        guard let history = StockExchange.sharedInstance.stockHistoriesByTicker[depot.ticker] else
        {
            return false
        }
        
        if dayIndex < 0 || dayIndex + previousDaysRequired >= history.count
        {
            return false
        }
        
        // just so derived classes don't have to get this themselves...
        stockHistory = history
        
        // do the actual trading
        tradeOnMarketOpening(dayIndex, depot: depot)
        tradeOnMarketClosing(dayIndex, depot: depot)
        
        return true
    }
    
    func tradeOnMarketOpening(_ day: Int, depot: Depot) {}
    
    func tradeOnMarketClosing(_ day: Int, depot: Depot) {}
    
    var stockHistory: [StockDayData] = []

    var name = "inactive trader"
    
    var previousDaysRequired = 0
}
