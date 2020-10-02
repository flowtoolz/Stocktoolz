//
//  File.swift
//  StockToolz
//
//  Created by Sebastian on 27/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class YahooCSVCrawler
{
    func downloadAllHistoricStockData()
    {
        saveHistoricStockDataForTickerListInDirectory("DAX")
        saveHistoricStockDataForTickerListInDirectory("TecDAX")
        saveHistoricStockDataForTickerListInDirectory("MDAX")
        saveHistoricStockDataForTickerListInDirectory("SDAX")
    }
    
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
        let urlString = "https://ichart.finance.yahoo.com/table.csv?s=" + ticker + "&g=d"
        
        guard let url = URL(string: urlString) else {
            print("could not create url: \(urlString)")
            return
        }
        
        DispatchQueue.global().async {
            do {
                let text = try String(contentsOf: url)
                self.saveTextToFile(text, fileName: directoryName + "/" + ticker + ".txt")
            }
            catch {
                print(error.localizedDescription)
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
