//
//  File.swift
//  StockToolz
//
//  Created by Sebastian on 31/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class MovingAverageTrader: Trader
{
    override init()
    {
        super.init()
        
        name = "moving average trader"
        
        previousDaysRequired = Statistics.movingAverageOverNumberOfDays
    }
    
    override func tradeOnMarketClosing(_ day: Int, depot: Depot)
    {
        // get data
//        let openingPrice = stockHistory[day].open
        let closingPrice = stockHistory[day].close
        
//        let previousOpeningPrice = stockHistory[day + 1].open
//        let previousClosingPrice = stockHistory[day + 1].close
        
        guard let movingAverages = Statistics.sharedInstance.movingAveragesByTicker[depot.ticker] else
        {
            return
        }
        
        let previousMovingAverage = movingAverages[day + 1]
        
        // apply strategy
        if closingPrice / previousMovingAverage > 1.00
        {
            depot.buy(day, onMarketOpening: false)
        }
        else if closingPrice / previousMovingAverage < 0.995
        {
            depot.sell(day, onMarketOpening: false)
        }
    }
}
