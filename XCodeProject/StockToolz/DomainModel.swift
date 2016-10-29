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
    
    var stockExchange = StockExchange()

    var focusRangeLatestDay = 0
    var focusRangeOldestDay = 261
}

