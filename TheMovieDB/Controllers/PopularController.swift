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
    
    static func getPeopleByIdName(idName: Int64) -> People? {
        
        if idName == 0 { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: People.type)
        let predicate = NSPredicate(format: "id == %@", argumentArray: [idName])
        request.predicate = predicate
        
        let resultsArray = (try? CoreDataManager.shared.viewContext.fetch(request)) as? [People]
        
        return resultsArray?.first ?? nil
    }

    
    static func getFromCore(completion: @escaping (Result<[People]>) -> Void) {
        NetworkManager.getFromTMDB() { result in
            switch result {
            case .success(let popularDict):
                var peoples = [People]()
                
                let moc = CoreDataManager.shared.backgroundContext
                moc?.perform{
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
                                print("Error: Could not create a new TrainingExcersise from the CloudKit record.")
                                continue
                            }
                            
                            peoples.append(newPeople)
                        } //else
                    } //for  element in popularDict

                    
                    CoreDataManager.shared.saveContext()
                    completion(Result.success(peoples))
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
                    
                    let thumbnail = ImageController.ResizeImage(image: image, newWidth: 300)
                    
                    people.thumbnail = UIImagePNGRepresentation(thumbnail)
                    people.photo = data
                    CoreDataManager.shared.saveContext()
                    
                    switch imageSize {
                    case .original:
                        completion(image)
                    case .thumbnail:
                        completion(thumbnail)
                    }
                    
                }
            
        } //else
        
    }
    
    static func loadImage(people: People) {
        DispatchQueue.main.async {
            if let profile_path = people.profile_path,
                let url = URL(string: TMDBConfig.buildImagePathX3(poster_path: profile_path)),
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            {
                
                let thumbnail = ImageController.ResizeImage(image: image, newWidth: 300)
                
                let moc = CoreDataManager.shared.backgroundContext
                moc?.perform {
                    people.thumbnail = UIImagePNGRepresentation(thumbnail)
                    people.photo = data
                    CoreDataManager.shared.saveContext()
                }
                
            }
            
        }
    }
    
    
    
}
