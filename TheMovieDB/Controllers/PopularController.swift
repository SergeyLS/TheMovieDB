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

enum ImageSize {
    case original
    case thumbnail
}



class PopularController {
    
    /* CODEREVIEW_9
     Я бы перенес весь код по работе с сетью в NetworkManager, а парсинг в Manager подобный этому. Мне только название не нравится 'PopularController' - визуально срабатывает что это ViewController.
     */
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
                //fatalError(error as! String)
                completion(Result.failure(error!))
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

    
    
    /* CODEREVIEW_11
     Колбэк тебе не нужен. Когда данные в базе обновляются NSFetchedResultsController об этом узнает и запускает делегата controllerDidChangeContent(_ controller:)
     */
    static func getFromCore(completion: @escaping (Result<[People]>) -> Void) {
        
//        let moc = Stack.shared.managedObjectContext
        let moc = Stack.shared.backgroundContext
        
        PopularController.getFromTMDB() { result in
            switch result {
            case .success(let popularDict):
                var peoples = [People]()
                
                /* CODEREVIEW_10
                 Весь парсинг в бэкграунде запустить и операцию сохранить БД запустить тоьлко в конце когда все сущности уже занесены в контекст
                 */
                moc.perform{
                    for  element in popularDict {
                        guard let id = element["id"] as? Int64 else {
                            continue
                        }
                        
                        if let existPeople = getPeopleByIdName(idName: Int64(id) )  {
                            //update
                            //print("id exist:" + String(id))
                            peoples.append(existPeople)
                        } else {
                            // New
                            guard let newPeople = People(dictionary: element as NSDictionary) else {
                                
                                /* CODEREVIEW_13
                                 Используй print вместо NSLog
                                 */
                                NSLog("Error: Could not create a new TrainingExcersise from the CloudKit record.")
                                continue
                            }
                            
                            peoples.append(newPeople)
                        } //else
                    } //for  element in popularDict

                    PersistenceController.shared.saveContext()
                }
                
            case .failure(let error):
                //print(error)
                
                completion(Result.failure(error))
            }
        }
    }

    
    static func getImage(people: People, imageSize: ImageSize, completion: @escaping (_ image: UIImage) -> Void)  {
        
        if let fotoOriginal = people.photo,
            let fotoThumbnail = people.thumbnail
        {
            
            switch imageSize {
            case .original:
                completion(UIImage(data: fotoOriginal)!)
            case .thumbnail:
                completion(UIImage(data: fotoThumbnail)!)
            }
            
            
        } else {
            
            if let profile_path = people.profile_path,
                let url = URL(string: TMDBConfig.buildImagePathX3(poster_path: profile_path)),
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            {
                
               let thumbnail = ImageController.ResizeImage(image: image, newWidth: 150)
                
               people.thumbnail = UIImagePNGRepresentation(thumbnail)
               people.photo = data
               PersistenceController.shared.saveContext()
                
                switch imageSize {
                case .original:
                    completion(image)
                case .thumbnail:
                    completion(thumbnail)
                }
              
            }
            
            
            
        } //else
        
    }
    
    
}
