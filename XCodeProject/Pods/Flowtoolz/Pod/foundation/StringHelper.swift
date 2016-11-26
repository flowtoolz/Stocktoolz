import Foundation

public extension String
{
    /*
    func hasPrefix(prefix: String) -> Bool
    {
        if prefix.length() > self.length()
        {
            return false
        }
        
        return self[0..<prefix.length()] == prefix
    }*/
    
    subscript(index: Int) -> Character
    {
        return self[index] as Character
    }
    
    func length() -> Int
    {
        return self.characters.count
    }
}
