//
//  Stack.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/29/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/* CODEREVIEW_0
 1. Stack - плохое название для класса - непонятно стек чего? У меня есть подобный класс, но с названием CoreDataManager
 2. В AppDelegate.swift уже есть код, который делает тоже самое, но чуть лучше (твой вариант тоже рабочий). Я бы перенес код иp AppDelegate.swift сюда и расширил по необходимости
 */
class Stack {
    
    static let shared = Stack()
    
/* CODEREVIEW_1
     viewContext - для main среда (при работе с UI элементами(таблицами))
     backgroundContext - для любых тасков в бэкграунде (сохранение/удаление/обновление данных в локальной базе)
 */
    lazy var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var backgroundContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
    
    lazy var managedObjectContext: NSManagedObjectContext = Stack.setUpMainContext()

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
    
}
