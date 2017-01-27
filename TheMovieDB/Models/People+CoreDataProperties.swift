//
//  People+CoreDataProperties.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation
import CoreData


extension People {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<People> {
        return NSFetchRequest<People>(entityName: "People");
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var popularity: Int64
    
    /* CODEREVIEW_1
     Фотки лучше не хранить в базе. Скорость сохранения на диске быстрее.
     База подходит только для хранения thumbnail-ов
     Фотки лучше кэшировать в каком нить фолдере
     Дополнительное задание: Закачивать картинки размером 'original' и в background-е 
     преобразовывать их под нужные тебе размеры и только потом загружать в селы
     */
    @NSManaged public var photo: NSData?

}
