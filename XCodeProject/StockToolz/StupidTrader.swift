//
//  StupidTrader.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class StupidTrader: Trader
{
    override init()
    {
        super.init()
        
        name = "stupid trader"
    }
    
    override func tradeOnMarketClosing(_ day: Int, depot: Depot)
    {
        // get prices
        let openingPrice = stockHistory[day].open
        let closingPrice = stockHistory[day].close
        
        let previousOpeningPrice = stockHistory[day + 1].open
        let previousClosingPrice = stockHistory[day + 1].close
        
        // apply strategy
        if previousClosingPrice < openingPrice && openingPrice < closingPrice
        {
            depot.buy(day, onMarketOpening: false)
        }
        else if closingPrice < previousOpeningPrice
        {
            depot.sell(day, onMarketOpening: false)
        }
    }
}
