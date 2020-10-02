//
//  Benchmark.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

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
        growthPerYear = pow(growthPerTradingDay, Double(tradingDaysPerYear))
        
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
