//
//  NSDate+Extension.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 21/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation
/*
func < (left: Date, right: Date) -> Bool
{
    return left.compare(right) == .orderedAscending
}
*/

public extension Date
{
    static func dayFromJSONDateString(_ json: String) -> Date?
    {
        let onlyDayString = json.components(separatedBy: "T")[0]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"//'T'HH:mm:ss.sssz"
        
        guard let date = formatter.date(from: onlyDayString) else
        {
            return nil
        }
        
        return date
    }
    
    func stringWithFormat(format: String) -> String
    {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
}
