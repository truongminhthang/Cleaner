//
//  ViewControllerHelper.swift
//  Cleaner
//
//  Created by Quốc Đạt on 10.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit


func showAlert(vc: UIViewController, title:String, message: String) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in}
    
    alertController.addAction(okAction)
    
    vc.present(alertController, animated: true, completion: nil)
}
