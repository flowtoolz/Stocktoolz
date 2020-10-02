//
//  StockExchangeDataInjector.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class StockExchangeDataInjector
{
    static func reloadStockExchangeData(rootFolder: URL)
    {
        StockExchange.sharedInstance.removeAllData()
        
        for stockGroupName in ["TecDAX", "DAX", "MDAX", "SDAX"]
        {
            var stockHistoryGroup = StockHistoryGroup()
            
            stockHistoryGroup.name = stockGroupName
            
            let groupFolder = rootFolder.appendingPathComponent(stockGroupName)
            
            stockHistoryGroup.stockHistoriesByTicker = YahooCSVParser().getStockHistories(fromDirectory: groupFolder)
            
            // for access by group/index
            StockExchange.sharedInstance.stockHistoryGroupsByName[stockGroupName] = stockHistoryGroup
            
            // for access by Ticker
            for (ticker, stockHistory) in stockHistoryGroup.stockHistoriesByTicker
            {
                StockExchange.sharedInstance.stockHistoriesByTicker[ticker] = stockHistory
            }
        }
        
        Statistics.sharedInstance.calculateAllMovingAverages()
    }
}
