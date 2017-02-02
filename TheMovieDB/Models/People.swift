//
//  People+CoreDataClass.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation
import CoreData


public class People: NSManagedObject {
    
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let type = "People"
    
    
    //==================================================
    // MARK: - Initializers
    //==================================================
//     convenience init?(id: Int64, name: String, photo: Data,_  context: NSManagedObjectContext = CoreDataManager.shared.managedObjectContext) {
//        
//        guard let tempEntity = NSEntityDescription.entity(forEntityName: People.type, in: context) else {
//            fatalError("Could not initialize LastDateUpdate")
//            return nil
//        }
//        self.init(entity: tempEntity, insertInto: context)
//        
//        self.id = id
//        self.name = name
//        self.photo = photo
//        self.profile_path = ""
//        
//    }
    
    
    convenience required public init?(dictionary: NSDictionary){
        guard let name = dictionary["name"] as? String,
            let profile_path = dictionary["profile_path"] as? String,
            let id = dictionary["id"] as? Int64
            else {
                return nil
        }
        
        guard let tempEntity = NSEntityDescription.entity(forEntityName: People.type, in: CoreDataManager.shared.viewContext) else {
            fatalError("Could not initialize People")
            return nil
        }
        self.init(entity: tempEntity, insertInto: CoreDataManager.shared.viewContext)

        
        self.name = name
        self.profile_path = profile_path
       
        self.id = id
        
        print("add people id: " + String(id))
    }



}
