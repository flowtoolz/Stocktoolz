//
//  YahooCSVParser.swift
//  StockToolz
//
//  Created by Sebastian on 27/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class YahooCSVParser
{
    func getStockHistories(fromDirectory directory: URL) -> [String : [StockDayData]]
    {
        var stockHistoriesByTicker = [String : [StockDayData]]()
        
        let tickers = getTickers(fromDirectory: directory)
        
        for ticker in tickers
        {
            // these data sets are damaged, compare degiro with yahoo finance and app ...
            if ["DBAN.DE", "AIR.DE"].contains(ticker)
            {
                continue
            }
            
            let stockDataFile = directory.appendingPathComponent(ticker + ".txt")
            let stockHistory = getStockDayData(fromFile: stockDataFile)
            
            stockHistoriesByTicker[ticker] = stockHistory
        }
        
        return stockHistoriesByTicker
    }
    
    func getTickers(fromDirectory directory: URL) -> [String]
    {
        let filePath = directory.appendingPathComponent("ticker_list.txt")
        
        let tickerListText = YahooCSVParser().readText(fromFile: filePath)
        
        var tickerArray: [String] = []
        
        tickerListText.enumerateLines
            {
                (line, someBool) in
                
                tickerArray.append(line)
        }
        
        return tickerArray
    }

    func getStockDayData(fromFile file: URL) -> [StockDayData]
    {
        // get data lines from file
        let text = readText(fromFile: file)
        
        let lines = getDataLinesFromText(text)

        guard lines.count > 0 else { return [] }
        
        // parse data lines into StockDayData objects
        var stockDayDataArray = [StockDayData]()
        
        for line in lines
        {
            if let stockDayData = getStockDayDataFromDataLine(line)
            {
                stockDayDataArray.append(stockDayData)
            }
            else
            {
                print("error: could not parse data line \"" + line + "\"")
            }
        }
        
        return stockDayDataArray
    }
    
    func readText(fromFile file: URL) -> String
    {
        var contentString = ""
        
        do
        {
            contentString = try String(contentsOf: file)
        }
        catch
        {
            print("could not read file from \"" + file.absoluteString + "\"")
        }
        
        return contentString
    }
    
    func getDataLinesFromText(_ text: String) -> [String]
    {
        var lines = [String]()
        
        text.enumerateLines
        {
            (line, someBool) in
                
            lines.append(line)
        }
        
        // remove table header
        if lines.count > 0
        {
            lines.remove(at: 0)
        }
        
        return lines
    }
    
    func getDataStringsFromLine(_ line: String) -> [String]?
    {
        let components = line.components(separatedBy: ",")
        
        if components.count != 7
        {
            print("error: line \"" + line + "\" has \(components.count) components but should have 7")
            
            return nil
        }
        
        return components
    }
    
    func getStockDayDataFromDataLine(_ line: String) -> StockDayData?
    {
        guard let dataStrings = getDataStringsFromLine(line) else
        {
            return nil
        }

        let stockDayData = StockDayData()
        
        stockDayData.date = StockDate(dateString: dataStrings[0])
        
        if let adjustedClose = Double(dataStrings[6]),
            let close = Double(dataStrings[4]),
            let open = Double(dataStrings[1]),
            let max = Double(dataStrings[2]),
            let min = Double(dataStrings[3]),
            let volume = Int64(dataStrings[5])
        {
            stockDayData.volume = volume
            stockDayData.adjustedClose = adjustedClose
            stockDayData.close = adjustedClose
            
            let adjustmentFactor = adjustedClose / close
            
            stockDayData.open = open * adjustmentFactor
            stockDayData.max = max * adjustmentFactor
            stockDayData.min = min * adjustmentFactor
        }
        else
        {
            print("could not read stock day data from CSV line: " + line)
            return nil
        }
        
        return stockDayData
    }
}
