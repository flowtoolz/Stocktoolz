//
//  File.swift
//  StockToolz
//
//  Created by Sebastian on 27/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation
import Alamofire

class YahooCSVCrawler
{
    func saveHistoricStockDataForTickerListInDirectory(_ directoryName: String)
    {
        let parser = YahooCSVParser()
        let tickerArray = parser.getTickersFromDirectory(directoryName)
        
        var count = 0
        
        for ticker in tickerArray
        {
            saveHistoricStockDataToFileForTicker(ticker, directoryName: directoryName)
            
            count += 1
            print("saved historic data for \(count) tickers")
        }
    }
    
    func saveHistoricStockDataToFileForTicker(_ ticker: String, directoryName: String)
    {
        Alamofire.request("https://ichart.finance.yahoo.com/table.csv?s=" + ticker + "&g=d").responseString
        {
            response in
            
            if let text = response.result.value
            {
                self.saveTextToFile(text, fileName: directoryName + "/" + ticker + ".txt")
            }
        }
    }
    
    func saveTextToFile(_ text:String, fileName: String)
    {
        let filePath = FileManager.default.currentDirectoryPath + "/" + fileName
        
        do
        {
            try text.write(toFile: filePath,
                           atomically: false,
                           encoding: String.Encoding.utf8)
        }
        catch
        {
            print("error: could not write text to file \"" + fileName + "\"")
        }
    }
}
