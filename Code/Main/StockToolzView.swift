import AppKit
import UIToolz
import GetLaid

class StockToolzView: LayerBackedView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layoutViews()
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
    
    private func layoutViews()
    {
        // chart view
        addForAutoLayout(chartView)
        chartView >> allButBottom
        chartView.height >> height.at(0.75)
        chartView.timeRange = FocusedTimeRange.sharedInstance
        
        // load button
        let loadButton = addForAutoLayout(NSButton())
        loadButton.title = "Load"
        loadButton >> left.offset(10)
        loadButton >> bottom.offset(-10)
        loadButton.top >> chartView.bottom.offset(10)
        loadButton.width >> loadButton.height
        loadButton.action = #selector(loadStockDataIntoViews)
        
        // run button
        let runButton = addForAutoLayout(NSButton())
        runButton.title = "Run"
        runButton.left >> loadButton.right.offset(10)
        runButton >> bottom.offset(-10)
        runButton.top >> chartView.bottom.offset(10)
        runButton.width >> runButton.height
        runButton.action = #selector(runButtonClicked)
        
        // result view
        addForAutoLayout(resultView)
        resultView.left >> runButton.right.offset(10)
        resultView.top >> chartView.bottom.offset(10)
        resultView.isBezeled = false
        resultView.drawsBackground = false
        resultView.isEditable = false
        resultView.isSelectable = true
        resultView.preferredMaxLayoutWidth = 100
        // resultView.maximumNumberOfLines = 2
        
        // left buttons
        let leftButton = addForAutoLayout(NSButton())
        leftButton.title = "<"
        leftButton.left >> resultView.right.offset(10)
        leftButton >> bottom.offset(-10)
        leftButton.top >> chartView.bottom.offset(10)
        leftButton.width >> leftButton.height.at(0.5)
        leftButton.action = #selector(leftButtonClicked)
        
        // zoom in/out buttons
        let zoomInButton = addForAutoLayout(NSButton())
        zoomInButton.title = "> <"
        zoomInButton.left >> leftButton.right
        zoomInButton.top >> chartView.bottom.offset(10)
        zoomInButton.width >> leftButton.height
        zoomInButton.action = #selector(zoomInButtonClicked)
        
        let zoomOutButton = addForAutoLayout(NSButton())
        zoomOutButton.title = "<   >"
        zoomOutButton.left >> leftButton.right
        zoomOutButton >> bottom.offset(-10)
        zoomOutButton.top >> zoomInButton.bottom
        zoomOutButton >> zoomInButton.size
        zoomOutButton.action = #selector(zoomOutButtonClicked)
        
        // right buttons
        let rightButton = addForAutoLayout(NSButton())
        rightButton.title = ">"
        rightButton.left >> zoomOutButton.right
        rightButton >> bottom.offset(-10)
        rightButton.top >> chartView.bottom.offset(10)
        rightButton >> right.offset(-10)
        rightButton.width >> leftButton.height.at(0.5)
        rightButton.action = #selector(rightButtonClicked)
    }
    
    // MARK: Interaction
    
    @objc func zoomInButtonClicked()
    {
        FocusedTimeRange.sharedInstance.zoomIn()
        
        chartView.redraw()
    }
    
    @objc func zoomOutButtonClicked()
    {
        FocusedTimeRange.sharedInstance.zoomOut()
        
        chartView.redraw()
    }
    
    @objc func rightButtonClicked()
    {
        FocusedTimeRange.sharedInstance.shiftToFuture()
        
        chartView.redraw()
    }
    
    @objc func leftButtonClicked()
    {
        FocusedTimeRange.sharedInstance.shiftToPast()
        
        chartView.redraw()
    }
    
    @objc func runButtonClicked()
    {
        resultView.stringValue = "NOt IMPLEMENTED"
    }
    
    @objc func loadStockDataIntoViews()
    {
        resultView.stringValue = "Selecting folder ..."
        
        FolderSelectionPanel().selectFolder
        {
            folder in

            //        YahooCSVCrawler().downloadAllHistoricStockData()
            StockExchangeDataInjector.reloadStockExchangeData(rootFolder: folder)
            self.chartView.redraw()
        }
    }
    
    var chartView = ChartView()
    var resultView = NSTextField()
}
