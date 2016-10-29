//
//  Benchmark.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class TraderPerformanceTest
{
    func run()
    {
        let traders = [StupidTrader(), LazyTrader()]
        
        var sumOfYearReturns = [0.0, 0.0]
        var numOfHistoriesTraded = [0, 0]
        var sumOfInconsistencies = [0.0, 0.0]
        
        for ticker in StockExchange.sharedInstance.stockHistoriesByTicker.keys
        {
            var lazyPerformance = PerformanceMetrics()
            var stupidPerformance = PerformanceMetrics()
            
            for i in 0 ..< traders.count
            {
                let depot = Depot()
                depot.cash = 1000.0
                depot.ticker = ticker
                depot.depotValueRecord.append(depot.cash)
                
                let trader = traders[i]
                
                if trader.trade(fromOldestDayIndex: StockExchange.sharedInstance.focusRangeOldestDay,
                                toNewestDayIndex: StockExchange.sharedInstance.focusRangeLatestDay,
                                depot: depot)
                {
                    let performance = PerformanceMetrics(withValueHistory: depot.depotValueRecord)
                    
                    sumOfYearReturns[i] += performance.growthPerYear
                    sumOfInconsistencies[i] += performance.growthInconsistency
                    numOfHistoriesTraded[i] += 1
                    
                    //print(trader.name + " year return: \(performance.growthPerYear)")
                    /*
                     if performance.growthInconsistency < 0.03 && trader.numTradingDays > 262 * 3 && trader.name == "lazy trader"
                     {
                     print(groupName + " - " + ticker + ": inconsistency of: \(performance.growthInconsistency) (\(trader.name))")
                     }
                     */
                    if i == 0
                    {
                        stupidPerformance = performance
                    }
                    else
                    {
                        lazyPerformance = performance
                    }
                }
                else
                {
                    print("could not trade " + ticker + " in the " + " group")
                }
            }
            /*
             let growthDifference = abs(lazyPerformance.growthPerYear - stupidPerformance.growthPerYear)
             
             if growthDifference > 0.3 && growthDifference <= 0.4
             {
             print(groupName + " - " + ticker + ": lazy return \(lazyPerformance.growthPerYear) stupid return \(stupidPerformance.growthPerYear)")
             }
             */
        }
        
        // print results
        resultString = ""
        
        for i in 0 ..< traders.count
        {
            let trader = traders[i]
            
            resultString.append(trader.name + ":\ncompanies traded: \(numOfHistoriesTraded[i])\nresult normalized for \(tradingDaysPerYear) trading days\nyearly growth: \(sumOfYearReturns[i] / Double(numOfHistoriesTraded[i]))\ninconsistency: \(sumOfInconsistencies[i] / Double(numOfHistoriesTraded[i]))\n")
        }
        
        //print(resultString)
    }
    
    var resultString = ""
}

struct PerformanceMetrics
{
    init() {}
    
    init(withValueHistory history: [Double])
    {
        guard history.count > 1,
            let newestValue = history.first,
            let oldestValue = history.last else
        {
            growthPerYear = 1.0
            growthInconsistency = 0.0
            
            return
        }
        
        // yearly growth
        let totalTradingDays = Double(history.count - 1)
        let totalReturn = newestValue / oldestValue
        let growthPerTradingDay = pow(totalReturn, 1.0 / totalTradingDays)
        growthPerYear = pow(growthPerTradingDay, tradingDaysPerYear)
        
        // inconsistency
        var sumOfDeviations = 0.0
        
        let lastIndex = history.count - 1
        
        for index in (0 ..< lastIndex).reversed()
        {
            let tradingDays = lastIndex - index
            let value = history[index]
            let estimatedGrowth = pow(growthPerTradingDay, Double(tradingDays))
            let optimalValue = oldestValue * estimatedGrowth
            
            let relativeDeviation = abs(value - optimalValue) / optimalValue
            sumOfDeviations += pow(relativeDeviation, 2.0)
        }
        
        growthInconsistency = sumOfDeviations / totalTradingDays
    }
    
    var growthPerYear: Double = 0.0
    var growthInconsistency: Double = 0.0
}

let tradingDaysPerYear = 262.0
