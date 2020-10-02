import UIToolz
import AppKit

class StockToolzController: AppController
{
    override init()
    {
        super.init()
        NSApplication.shared.mainMenu = MainMenu() // must be set before delegate
        window.contentView = StockToolzView()
    }
}
