//
//  NSURL+Extension.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 11/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation

public extension URL
{
    func queryDictionary() -> [String: String]?
    {
        guard let queryString = "\(self)".components(separatedBy: "?").last else
        {
            return nil
        }
        
        var query = [String: String]()
        
        let queryComponents = queryString.components(separatedBy: "&")
        
        for queryComponent in queryComponents
        {
            let keyValuePair = queryComponent.components(separatedBy: "=")
            
            guard keyValuePair.count == 2 else
            {
                continue
            }
            
            let key = keyValuePair[0]
            let value = keyValuePair[1].removingPercentEncoding
            
            query[key] = value
        }
        
        guard query.keys.count > 0 else
        {
            return nil
        }
        
        return query
    }
}
