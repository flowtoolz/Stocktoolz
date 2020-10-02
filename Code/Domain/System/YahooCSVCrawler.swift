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
    func downloadAllHistoricStockData(toRootFolder rootFolder: URL)
    {
        for group in ["DAX", "TecDAX", "MDAX", "SDAX"]
        {
            let folder = rootFolder.appendingPathComponent(group)
            saveHistoricStockDataForTickerList(inDirectory: folder)
        }
    }
    
    func saveHistoricStockDataForTickerList(inDirectory directory: URL)
    {
        let parser = YahooCSVParser()
        let tickerArray = parser.getTickers(fromDirectory: directory)
        
        var count = 0
        
        for ticker in tickerArray
        {
            saveHistoricStockDataToFileForTicker(ticker, directory: directory)
            
            count += 1
            print("saved historic data for \(count) tickers")
        }
    }
    
    func saveHistoricStockDataToFileForTicker(_ ticker: String, directory: URL)
    {
        let urlString = "https://ichart.finance.yahoo.com/table.csv?s=" + ticker + "&g=d"
        
        guard let url = URL(string: urlString) else {
            print("could not create url: \(urlString)")
            return
        }
        
        let file = directory.appendingPathComponent(ticker + ".txt")
        
        DispatchQueue.global().async {
            do {
                let text = try String(contentsOf: url)
                self.save(text, toFile: file)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func save(_ text: String, toFile file: URL)
    {
        do
        {
            try text.write(toFile: file.absoluteString,
                           atomically: false,
                           encoding: String.Encoding.utf8)
        }
        catch
        {
            print("error: could not write text to file \"" + file.absoluteString + "\"")
        }
    }
}
