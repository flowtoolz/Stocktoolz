//
//  StockExchange.swift
//  StockToolz
//
//  Created by Sebastian on 29/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class StockExchange
{
    var stockHistoriesByTicker: [String : [StockDayData]] = [:]
    var stockHistoryGroupsByName: [String : StockHistoryGroup] = [:] // indices
}

struct StockHistoryGroup
{
    var stockHistoriesByTicker: [String : [StockDayData]] = [:]
    
    var name = ""
}

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
