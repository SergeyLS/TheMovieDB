//
//  ProgressHUBController.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation
import MBProgressHUD

class ProgressHUBController {
    
    static func show(label: String) {
        let view = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view
        let hud = MBProgressHUD.showAdded(to: view!, animated: true)
        hud.label.text = label
        hud.progress = 0.0
        hud.WSStyle()
    }
    
    static func show(view: UIView, label: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = label
        hud.progress = 0.0
        hud.WSStyle()
    }
    
    static func hide() {
        let view = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view
        MBProgressHUD.hide(for: view!, animated: true)
    }
    
    static func hide(_ view: UIView) {
        //        DispatchQueue.main.async(execute: { () -> Void in
        //            MBProgressHUD.hide(for: view, animated: true)
        //        })
        MBProgressHUD.hide(for: view, animated: true)
    }
    
}

extension MBProgressHUD {
    func WSStyle() {
        self.removeFromSuperViewOnHide = true
    }
}
