//
//  DomainModel.swift
//  StockToolz
//
//  Created by Sebastian on 27/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class DomainModel: NSObject
{
    // MARK: Singleton Access & Initialization
    
    public static let sharedInstance = DomainModel()
    
    override private init()
    {
        super.init()
        
        initialize()
    }
    
    private func initialize()
    {
        
    }
    
    // Entrance point
    
    func run()
    {        
        let traders = [StupidTrader(), LazyTrader()]
        
        var sumOfYearReturns = [0.0, 0.0]
        var numOfHistoriesTraded = [0, 0]
        var sumOfInconsistencies = [0.0, 0.0]
        
        for groupName in stockHistoryGroupsByName.keys
        {
            if let stockHistoryGroup = stockHistoryGroupsByName[groupName]
            {
                for ticker in stockHistoryGroup.stockHistoriesByTicker.keys
                {
                    // these data sets are damaged, compare degiro with yahoo finance...
                    if ["DBAN.DE", "AIR.DE"].contains(ticker)
                    {
                        continue
                    }
                    
                    if let stockHistory = stockHistoryGroup.stockHistoriesByTicker[ticker]
                    {
                        var lazyPerformance = PerformanceMetrics()
                        var stupidPerformance = PerformanceMetrics()
                        
                        for i in 0 ..< traders.count
                        {
                            let trader = traders[i]
 
                            if trader.trade(stockHistory)
                            {
                                let performance = PerformanceMetrics(withValueHistory: trader.depotValueRecord)
                                
                                sumOfYearReturns[i] += performance.growthPerYear
                                sumOfInconsistencies[i] += performance.growthInconsistency
                                numOfHistoriesTraded[i] += 1
                                
                                //print("year return over \(tradedTradingDays) trading days: \(returnPerYear)")
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
                                print("could not trade " + ticker + " in the " + groupName + " group")
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
                }
            }
        }
        
        // print results
        for i in 0 ..< traders.count
        {
            let trader = traders[i]
            print(trader.name + ":\ncompanies traded: \(numOfHistoriesTraded[i])\nresult normalized for \(tradingDaysPerYear) trading days\nyearly growth: \(sumOfYearReturns[i] / Double(numOfHistoriesTraded[i]))\ninconsistency: \(sumOfInconsistencies[i] / Double(numOfHistoriesTraded[i]))")
        }
    }

    var stockHistoryGroupsByName: [String : StockHistoryGroup] = [:]
}

struct PerformanceMetrics
{
    init()
    {
        
    }
    
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

struct StockHistoryGroup
{
    var stockHistoriesByTicker: [String : [StockDayData]] = [:]
    
    var name = ""
}

class LazyTrader: Trader
{
    override init()
    {
        super.init()
        
        name = "lazy trader"
    }
    
    override func tradeOnMarketOpening(_ day: Int)
    {
        let openingPrice = stockHistory[day].open
 
        let buyNumber = cash / openingPrice

        cash = 0.0
        shares += buyNumber
        sharesBuyingPriceSum += buyNumber * openingPrice
    }
}

class StupidTrader: Trader
{
    override init()
    {
        super.init()
        
        name = "stupid trader"
    }
    
    override func tradeOnMarketClosing(_ day: Int)
    {
        let previousOpeningPrice = stockHistory[day + 1].open
        let previousClosingPrice = stockHistory[day + 1].close
        let openingPrice = stockHistory[day].open
        let closingPrice = stockHistory[day].close
        
        // if yesterday close < open < close
        if previousClosingPrice < openingPrice &&
            openingPrice < closingPrice
        {
            // buy as many shares as possible at closing price
            let buyNumber = cash / closingPrice
            
            //print("buying \(buyNumber) share(s)")
            
            cash -= buyNumber * closingPrice
            shares += buyNumber
            sharesBuyingPriceSum += buyNumber * closingPrice
        }
        else if closingPrice < previousOpeningPrice
        {
            // sell everything at closing price
            //print("selling \(shares) share(s)")
            cash += shares * closingPrice
            shares = 0.0
            sharesBuyingPriceSum = 0
        }
    }
}

class Trader
{
    func trade(_ stockDayDataArray: [StockDayData], debug: Bool = false) -> Bool
    {
        stockHistory = stockDayDataArray

        let numPreviousDaysRequiredToTrade = 1
        let maxTradingDays = Int(tradingDaysPerYear) * 5
        numTradingDays = min(stockDayDataArray.count - numPreviousDaysRequiredToTrade, maxTradingDays)
        
        if numTradingDays < 1
        {
            print("error: stock history has only \(stockDayDataArray.count) days but trader requires \(numPreviousDaysRequiredToTrade) previous days")
            return false
        }
        
        cash = startCash
        shares = 0.0
        sharesBuyingPriceSum = 0.0
        
        depotValueRecord.removeAll()
        depotValueRecord.append(startCash)
        
        for i in (0 ..< numTradingDays).reversed()
        {
            tradeOnMarketOpening(i)
            tradeOnMarketClosing(i)
            
            // record depot value so we can measure the over time consistency of traders
            depotValueRecord.insert(depotValue(i), at: 0)
        }
        
        return true
    }
    
    func depotValue(_ day: Int) -> Double
    {
        return cash + (shares * stockHistory[day].close)
    }
    
    func tradeOnMarketOpening(_ day: Int)
    {
       
    }
    
    func tradeOnMarketClosing(_ day: Int)
    {
        
    }

    var stockHistory: [StockDayData] = []
    var depotValueRecord = [Double]()
    
    let startCash = 1000.0
    var cash = 0.0
    var shares = 0.0
    var sharesBuyingPriceSum = 0.0
    var numTradingDays = 0
    var name = "inactive trader"
}

let tradingDaysPerYear = 262.0

class StockDayData
{
    func printLine()
    {
        print("\(date.year)/\(date.month)/\(date.day) \(open) \(max) \(min) \(close) \(volume) \(adjustedClose)")
    }
    
    var date = StockDate()
    
    var open: Double = 0
    var close: Double = 0
    
    var max: Double = 0
    var min: Double = 0
    
    var volume: Int64 = 0
    
    var adjustedClose: Double = 0
}

struct StockDate
{
    init()
    {
        
    }
    
    init(dateString: String)
    {
        year = 0
        month = 0
        day = 0
        
        let components = dateString.components(separatedBy: "-")
        
        guard components.count == 3 else
        {
            print("could not create stock date with date string \"" + dateString + "\"")
            return
        }
        
        if let y = Int(components[0])
        {
            year = y
        }
        
        if let m = Int(components[1])
        {
            month = m
        }
        
        if let d = Int(components[2])
        {
            day = d
        }
    }
    
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
}
