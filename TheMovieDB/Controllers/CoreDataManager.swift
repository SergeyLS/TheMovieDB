//
//  CoreDataManager.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/29/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class CoreDataManager {
    
    //==================================================
    // MARK: - Singleton
    //==================================================
    static let shared = CoreDataManager()
  
    //==================================================
    // MARK: - Properties
    //==================================================

    //viewContext - для main среда (при работе с UI элементами(таблицами))
    //backgroundContext - для любых тасков в бэкграунде (сохранение/удаление/обновление данных в локальной базе)
    lazy var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var backgroundContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
    lazy var managedObjectContext: NSManagedObjectContext = CoreDataManager.setUpMainContext()
    
    
    //==================================================
    // MARK: - func
    //==================================================

    static func setUpMainContext() -> NSManagedObjectContext {
        let bundle = Bundle.main
        guard let model = NSManagedObjectModel.mergedModel(from: [bundle]) else {
            fatalError("model not found")
        }
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        //persistentStoreCoordinator.ide
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
                                                           at: storeURL(), options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }
    
    static func storeURL () -> URL? {
        let documentsDirectory: URL? = try? FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDirectory?.appendingPathComponent("db.sqlite")
    }
    
    
    //==================================================
    // MARK: - saveContext
    //==================================================
    func saveContext () {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    
    
}
