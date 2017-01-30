//
//  PopularController.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum Result<T> {
    case success(T)
    case failure(Error)
}


class PopularController {
    
    static func getFromTMDB(completion: @escaping (Result<[[String : AnyObject]]>) -> Void) {
        
        //let stringURL = TMDBConfig.popular + TMDBConfig.API_KEY + "&language=en-US&page=1"
        
        let stringURL = TMDBConfig.popular + TMDBConfig.API_KEY + "&language=en-US&page=1"
        
        let url = URL(string: stringURL)!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data,
                let dataDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any],
                let popularsRep = dataDictionary["results"] as? [[String : AnyObject]]
                {
                completion(Result.success(popularsRep))
                
            } else {
                fatalError(error as! String)
             }
            
         }
        task.resume()
        
    }
    
    
    static func getPeopleByIdName(idName: Int64) -> People? {
        
        if idName == 0 { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: People.type)
        let predicate = NSPredicate(format: "id == %@", argumentArray: [idName])
        request.predicate = predicate
        
        let resultsArray = (try? Stack.shared.managedObjectContext.fetch(request)) as? [People]
        
        return resultsArray?.first ?? nil
    }

    
    
    static func getFromCore(completion: @escaping (Result<[People]>) -> Void) {
        
        let moc = Stack.shared.managedObjectContext
        
        PopularController.getFromTMDB() { result in
            switch result {
            case .success(let popularDict):
                var peoples = [People]()
                
                for  element in popularDict {
                    guard let id = element["id"] as? Int64
                        else { return }

                    moc.performAndWait({
                        
                        if let existPeople = getPeopleByIdName(idName: Int64(id) )  {
                            //update
                            //print("id exist:" + String(id))
                            peoples.append(existPeople)
                          }else{
                            // New
                            guard let newPeople = People(dictionary: element as NSDictionary) else {
                                
                                NSLog("Error: Could not create a new TrainingExcersise from the CloudKit record.")
                                return
                            }
                            
                            PersistenceController.shared.saveContext()
                            
                            peoples.append(newPeople)
                        } //else
                     }) //performAndWait
                } //for  element in popularDict
               
                
                completion(Result.success(peoples))
                
            case .failure(let error):
                //print(error)
                fatalError(error as! String)
            }
        }
       
        
    }

    
    
    
}
