//
//  Depot.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class Depot
{
    func value(_ dayIndex: Int) -> Double?
    {
        guard let stockHistory = StockExchange.sharedInstance.stockHistoriesByTicker[ticker] else
        {
            return nil
        }
        
        let closingPrice = stockHistory[dayIndex].close
        
        return cash + (shares * closingPrice)
    }
    
    var depotValueRecord = [Double]()
    
    func buy(_ dayIndex: Int, onMarketOpening: Bool)
    {
        guard let stockHistory = StockExchange.sharedInstance.stockHistoriesByTicker[ticker] else
        {
            return
        }
        
        let price = onMarketOpening ? stockHistory[dayIndex].open : stockHistory[dayIndex].close
        
        shares += cash / price
        cash = 0.0
    }
    
    func sell(_ dayIndex: Int, onMarketOpening: Bool)
    {
        guard let stockHistory = StockExchange.sharedInstance.stockHistoriesByTicker[ticker] else
        {
            return
        }
        
        let price = onMarketOpening ? stockHistory[dayIndex].open : stockHistory[dayIndex].close
        
        cash += shares * price
        shares = 0.0
    }
    
    var shares: Double = 0.0
    var cash: Double = 0.0
    
    var ticker: String = ""
}
