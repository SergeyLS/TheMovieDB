//
//  Stack.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/29/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation
import CoreData

class Stack {
    
    static let shared = Stack()
    
    lazy var managedObjectContext: NSManagedObjectContext = Stack.setUpMainContext()
    
    static func setUpMainContext() -> NSManagedObjectContext {
        let bundle = Bundle.main
        guard let model = NSManagedObjectModel.mergedModel(from: [bundle])
            else { fatalError("model not found") }
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        //persistentStoreCoordinator.ide
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
                                                           at: storeURL(), options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        let context = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }
    
    static func storeURL () -> URL? {
        let documentsDirectory: URL? = try? FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDirectory?.appendingPathComponent("db.sqlite")
    }
    
}
