//
//  ImageController.swift
//  OnlineTrainer
//
//  Created by Sergey Leskov on 9/30/16.
//  Copyright © 2016 Sergey Leskov. All rights reserved.
//

import Foundation
import UIKit

/* CODEREVIEW_15
 Лучше перенести код в расширение UIImage. Например UIImage+Extension.swift
 */

class ImageController {
    
    
    static func ResizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        var height = image.size.height
        var width = image.size.width
        
        if width > height  {
            let scale = newWidth / image.size.width
            height = image.size.height * scale
            width = newWidth
        } else {
            let scale = newWidth / image.size.height
            width = image.size.width * scale
            height = newWidth
        }
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        
        
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    static func imageToDataAndResize(image: UIImage?, newWidth: CGFloat) -> Data {
        var returnImage = UIImage()
        if let tempImage = image {
            returnImage = tempImage
        }
        returnImage = ResizeImage(image: returnImage, newWidth: newWidth)
        
        return UIImagePNGRepresentation(returnImage)!
    }

    
}
