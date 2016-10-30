//
//  FocusedTimeRange.swift
//  StockToolz
//
//  Created by Sebastian on 30/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class FocusedTimeRange : TradingTimeRange
{
    // MARK: Singleton Access
    
    public static let sharedInstance = FocusedTimeRange()
    
    override private init(firstTradingDayIndex firstDayIndex: Int, lastTradingDayIndex lastDayIndex: Int)
    {
        super.init(firstTradingDayIndex: firstDayIndex, lastTradingDayIndex: lastDayIndex)
    }
    
    // MARK: Change Range
    
    func zoomIn()
    {
        let step = (firstTradingDayIndex - lastTradingDayIndex) / 20
        
        lastTradingDayIndex += step
        firstTradingDayIndex -= step
    }

    func zoomOut()
    {
        let step = (firstTradingDayIndex - lastTradingDayIndex) / 20
        
        lastTradingDayIndex -= step
        firstTradingDayIndex += step
    }

    func shiftToPast()
    {
        let step = (firstTradingDayIndex - lastTradingDayIndex) / 20
        
        lastTradingDayIndex += step
        firstTradingDayIndex += step
    }

    func shiftToFuture()
    {
        let step = (firstTradingDayIndex - lastTradingDayIndex) / 20
        
        lastTradingDayIndex -= step
        firstTradingDayIndex -= step
    }
}
