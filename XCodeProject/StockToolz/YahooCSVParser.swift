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
    func getStockHistoriesFromDirectory(_ directoryName: String) -> [String : [StockDayData]]
    {
        var stockHistoriesByTicker = [String : [StockDayData]]()
        
        let tickers = getTickersFromDirectory(directoryName)
        
        for ticker in tickers
        {
            // these data sets are damaged, compare degiro with yahoo finance and app ...
            if ["DBAN.DE", "AIR.DE", "SRT3.DE"].contains(ticker)
            {
                continue
            }
            
            let stockHistory = getStockDayDataFromFile(directoryName + "/" + ticker + ".txt")
            
            stockHistoriesByTicker[ticker] = stockHistory
        }
        
        return stockHistoriesByTicker
    }
    
    func getTickersFromDirectory(_ directoryName: String) -> [String]
    {
        let filePath = directoryName + "/" + "ticker_list.txt"
        
        let tickerListText = YahooCSVParser().readTextFromFile(filePath)
        
        var tickerArray: [String] = []
        
        tickerListText.enumerateLines
            {
                (line, someBool) in
                
                tickerArray.append(line)
        }
        
        return tickerArray
    }

    func getStockDayDataFromFile(_ fileName: String) -> [StockDayData]
    {
        // get data lines from file
        let text = readTextFromFile(fileName)
        
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
    
    func readTextFromFile(_ fileName: String) -> String
    {
        let fm = FileManager()
        
        let filePath = fm.currentDirectoryPath + "/" + fileName
        
        var contentString = ""
        
        do
        {
            contentString = try String(contentsOfFile: filePath)
        }
        catch
        {
            print("could not read file from \"" + filePath + "\"")
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
        
        // date
        let dateString = dataStrings[0]
        
        stockDayData.date = StockDate(dateString: dateString)
        
        // open
        if let open = Double(dataStrings[1])
        {
            stockDayData.open = open
        }
        else
        {
            print("could not read opening price")
        }
        
        // max
        if let max = Double(dataStrings[2])
        {
            stockDayData.max = max
        }
        else
        {
            print("could not read maximum price")
        }
        
        // min
        if let min = Double(dataStrings[3])
        {
            stockDayData.min = min
        }
        else
        {
            print("could not read minimum price")
        }
        
        // close
        if let close = Double(dataStrings[4])
        {
            stockDayData.close = close
        }
        else
        {
            print("could not read closing price")
        }
        
        // volume
        if let volume = Int64(dataStrings[5])
        {
            stockDayData.volume = volume
        }
        else
        {
            print("could not read volume")
        }
        
        // adjusted close
        if let ac = Double(dataStrings[6])
        {
            stockDayData.adjustedClose = ac
        }
        else
        {
            print("could not read adjusted closing price")
        }
        
        return stockDayData
    }
}
