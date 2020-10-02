//
//  File.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class Statistics
{
    func calculateAllMovingAverages()
    {
        movingAveragesByTicker.removeAll()
        
        let exchange = StockExchange.sharedInstance
        
        for ticker in exchange.stockHistoriesByTicker.keys
        {
            guard let history = exchange.stockHistoriesByTicker[ticker] else
            {
                return
            }
            
            movingAveragesByTicker[ticker] = movingAverageForStockHistory(stockHistory: history,
                                                                          numberOfDays: Statistics.movingAverageOverNumberOfDays)
        }
    }
    
    var movingAveragesByTicker = [String : [Double]]()
    
    static let movingAverageOverNumberOfDays = 1
    
    // Singleton
    
    static let sharedInstance = Statistics()
    
    private init() {}
}

func movingAverageForStockHistory(stockHistory history: [StockDayData], numberOfDays: Int) -> [Double]?
{
    if numberOfDays > history.count
    {
        print("error: not enough days in history to calculate moving average \(numberOfDays)")
        
        return nil
    }
    var movingAverage = [Double]()
    
    var sum = 0.0
    
    for i in (0 ..< history.count)
    {
        sum += history[i].close
        
        if i + 1 < numberOfDays
        {
            continue
        }

        movingAverage.append(sum / Double(numberOfDays))
        
        let indexOfAverage = i - (numberOfDays - 1)
        
        sum -= history[indexOfAverage].close
    }
    
    return movingAverage
}

func statisticsForStockHistory(stockHistory history: [StockDayData],
                               tradingDayRange: TradingTimeRange) -> MinumuAndMaximum
{
    var statistics = MinumuAndMaximum()
    
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

struct MinumuAndMaximum
{
    var minimum: Double = -1.0
    var maximum: Double = 0.0
    
    var maxVolume: Int64 = 0
}
