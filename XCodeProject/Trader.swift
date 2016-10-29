//
//  trader.swift
//  StockToolz
//
//  Created by Sebastian on 29/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class LazyTrader: Trader
{
    override init()
    {
        super.init()
        
        name = "lazy trader"
    }
    
    override func tradeOnMarketOpening(_ day: Int, depot: Depot)
    {
        depot.buy(day, onMarketOpening: true)
    }
}

class StupidTrader: Trader
{
    override init()
    {
        super.init()
        
        name = "stupid trader"
    }
    
    override func tradeOnMarketClosing(_ day: Int, depot: Depot)
    {
        let openingPrice = stockHistory[day].open
        let closingPrice = stockHistory[day].close
        
        let previousOpeningPrice = stockHistory[day + 1].open
        let previousClosingPrice = stockHistory[day + 1].close
        
        if previousClosingPrice < openingPrice &&
            openingPrice < closingPrice
        {
            depot.buy(day, onMarketOpening: false)
        }
        else if closingPrice < previousOpeningPrice
        {
            depot.sell(day, onMarketOpening: false)
        }
    }
}

class Trader
{
    func trade(fromOldestDayIndex oldestDay: Int,
               toNewestDayIndex newestDay: Int,
               depot: Depot) -> Bool
    {
        guard let history = DomainModel.sharedInstance.stockExchange.stockHistoriesByTicker[depot.ticker] else
        {
            return false
        }
        
        stockHistory = history
        
        let numPreviousDaysRequiredToTrade = 1
        
        // is focus range completely out of range of given stock history?
        if (newestDay >= stockHistory.count - numPreviousDaysRequiredToTrade) ||
            stockHistory.count - numPreviousDaysRequiredToTrade <= newestDay
        {
            return false
        }
        
        let tradingStartDay = min((stockHistory.count - 1) - numPreviousDaysRequiredToTrade, oldestDay)
        let tradingEndDay = newestDay
        
        let numTradingDays = (tradingStartDay - tradingEndDay) + 1
        
        if numTradingDays < 1
        {
            return false
        }
        
        for i in (tradingEndDay ... tradingStartDay).reversed()
        {
            if i < 0 || i >= stockHistory.count
            {
                continue
            }
            
            tradeOnMarketOpening(i, depot: depot)
            tradeOnMarketClosing(i, depot: depot)
            
            // record depot value so we can measure the over time consistency of traders
            if let depotValue = depot.value(i)
            {
                depot.depotValueRecord.insert(depotValue, at: 0)
            }
        }
        
        return true
    }
    
    func tradeOnMarketOpening(_ day: Int, depot: Depot)
    {
        
    }
    
    func tradeOnMarketClosing(_ day: Int, depot: Depot)
    {
        
    }
    
    var stockHistory: [StockDayData] = []

    var name = "inactive trader"
}
