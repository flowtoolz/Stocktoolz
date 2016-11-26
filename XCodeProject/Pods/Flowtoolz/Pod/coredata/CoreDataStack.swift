//
//  FT_CoreDataStack.swift
//  Flowtoolz Portfolio
//
//  Created by Sebastian Fichtner on 09.05.15.
//  Copyright (c) 2015 Flowtoolz. All rights reserved.
//

import Foundation
import CoreData

open class FT_CoreDataStack
{
    // MARK: - lazy loaded properties
    
    lazy var applicationDocumentsDirectory: URL =
    {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Flowtoolz.TodayList" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel =
    {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "TodayList", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? =
    {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("TodayList.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do
        {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        }
        catch var error1 as NSError
        {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        catch
        {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? =
    {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        
        if coordinator == nil
        {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - loading and saving
    
    func createObjectOfClass(_ className: String) -> NSManagedObject?
    {
        if let c = managedObjectContext
        {
            return NSEntityDescription.insertNewObject(forEntityName: className, into: c) as? NSManagedObject
        }
        
        return nil
    }
    
    func fetchObjectsOfClass(_ className: String) -> [NSManagedObject]
    {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: className)
        
        if let c = managedObjectContext,
            let fetchResults = (try? c.fetch(fetchRequest)) as? [NSManagedObject]
        {
            return fetchResults
        }
        else
        {
            NSLog("error fetching objects of class '%@' from core data", className)
            return []
        }
    }
    
    func fetchObjectsOfClass(_ className: String,
        withPredicate predicate: NSPredicate) -> [NSManagedObject]
    {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: className)
        fetchRequest.predicate = predicate
        
        if let c = managedObjectContext,
            let fetchResults = (try? c.fetch(fetchRequest)) as? [NSManagedObject]
        {
            return fetchResults
        }
        else
        {
            NSLog("error fetching objects of class '%@' from core data", className)
            return []
        }
    }
    
    func saveContext()
    {
        // FIXME: fix this with new try catch syntax
        /*
        if let moc = self.managedObjectContext
        {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save()
            {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
            else
            {
                NSLog("either nothing changed or data saving failed")
            }
        }
        */
    }
    
    // MARK: - singleton access & initialization
    
    private init() {}
    
    public static let sharedInstance: FT_CoreDataStack = FT_CoreDataStack()
}