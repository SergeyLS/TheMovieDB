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

    
    static func getFromCore(completion: @escaping () -> Void) {
        NetworkManager.getFromTMDB() { result in
            switch result {
            case .success(let popularDict):
                let moc = CoreDataManager.shared.newBackgroundContext
                moc.perform{ [weakMoc = moc] in
                    for  element in popularDict {
                        guard let id = element["id"] as? Int64 else {
                            continue
                        }
                        
                        if let _ = getPeopleByIdName(idName: Int64(id) )  {
                        } else {
                            // New
                            guard let _ = People.entity(dictionary: element as NSDictionary, context: weakMoc) else {
                                print("Error: Could not create a new TrainingExcersise from the CloudKit record.")
                                continue
                            }
                            
                        } //else
                    } //for  element in popularDict
                    
                    CoreDataManager.shared.save(context: weakMoc)
                    completion()
                }
                
            case .failure(_):
                completion()
            }
        }
    }

    
    /* CODEREVIEW_8
     Стремный способ загрузки картинок. Никогда так не делай. Используй USRLSession.
     Для того чтобы прервать такую загрузку нужно танцевать с бубном еще. А прерывать тебе прийдется часто: например если для cell на экране ты грузишь картинку, а в это време пользователь скроли таблицу и cell уходит с экрана - зугрузку нужно остановить, потому что cell попадет в очередь таблицы на переиспользование и когда от туда она снова попадет на экран, то ты запустишь загрузку уже другой картинки. При твоем подходе количество отновременных закачек с сервера неконтролируемо и может перегружать само приложение. Переделай на URLSession     
     */
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
                
               people.thumbnail = UIImagePNGRepresentation(thumbnail)
               people.photo = data
                
            }
            
        }
    }
    
    
    
}
