import UIToolz

@main
class StockToolzAppController: AppController
{
    static func main() { instance.startApp() }
    
    private static let instance = StockToolzAppController(appView: StockToolzView())
}
