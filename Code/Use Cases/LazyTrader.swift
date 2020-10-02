//
//  LazyTrader.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
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
