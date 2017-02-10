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

/* CODEREVIEW_4
 ОБЩИЕ ПРАВИЛА РАБОТЫ c CoreData:
 
 Правило 1. NSManagedObject (и все отнаследованные от него) так или иначе создаются с привязкой к контексту. Без привязки объект не имеет смысла. В этом его главное отличие от обычных классов.
 Правило 2. Если ты инстанциировал NSManagedObject в одном срэде (thread), то в другой его передавать нельзя
 Правило 3. Сохранять контекст можно только в его же срэде
 */

class CoreDataManager {
    
    //==================================================
    // MARK: - Singleton
    //==================================================
    static let shared = CoreDataManager()
    /* CODEREVIEW_0
     Твой синглтон не закончен. Нужен init который никто не может вызвать извне:
    */
    private init() {
    }

    //==================================================
    // MARK: - Properties
    //==================================================
    /* CODEREVIEW_1
     Я бы сделал эти проперти вычисляемыми, т.к. по сути они у тебя "мост" к вложенным пропертям
     */
    var viewContext: NSManagedObjectContext {
        get {
            let resultContext = persistentContainer.viewContext
            resultContext.automaticallyMergesChangesFromParent = true
            return resultContext
        }
    }
    var newBackgroundContext: NSManagedObjectContext {
        get {
            let resultContext = persistentContainer.newBackgroundContext()
            return resultContext
        }
    }
    
    //==================================================
    // MARK: - init
    //==================================================
//    init() {
//        viewContext = persistentContainer.viewContext
//        backgroundContext = persistentContainer.newBackgroundContext()
//    }
    
    
    //==================================================
    // MARK: - Core Data stack
    //==================================================
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TheMovieDB")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    
    //==================================================
    // MARK: - saveContext
    //==================================================
    func saveContext () {
        let context = persistentContainer.viewContext
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
    
    /* CODEREVIEW_6
     Более общий вариант предыдущей функции
     */
    public func save(context: NSManagedObjectContext) {
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
    
    //==================================================
    // MARK: - fetchedResultsController
    //==================================================
    public func newFetchedResultsController(entityName: String, keyForSort: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }
}
