//
//  PersistenceController.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/30/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//


import Foundation
import CoreData

/* CODEREVIEW_8
 PersistenceController и Stack - это одно и тоже перенеси весь код в одно место
 */

class PersistenceController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = PersistenceController()
    let moc = Stack.shared.managedObjectContext
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func saveContext() {
        
        do {
            try moc.save()
        } catch {
            
            print("Error: Failed to save the Managed Object Context")
            print(error)
        }
    }
    
}
