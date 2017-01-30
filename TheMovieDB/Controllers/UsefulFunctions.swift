//
//  UsefulFunctions.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/29/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation




class UsefulFunctions {
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
   
    //==================================================
    // MARK: - func
    //==================================================
    static func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version).\(build)"
    }
    
    
    
}
