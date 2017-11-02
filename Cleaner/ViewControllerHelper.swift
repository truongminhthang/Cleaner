//
//  ViewControllerHelper.swift
//  Cleaner
//
//  Created by Quốc Đạt on 10.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import SystemConfiguration



func showAlertToDeleteApp(title:String, message: String) {
    showAlertCompelete(title: title, message: message, settingUrl: "App-prefs:root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE")
}
func showAlertToOpenSetting( title:String, message: String) {
    showAlertCompelete(title: title, message: message, settingUrl: UIApplicationOpenSettingsURLString)

}

func showAlert(title:String, message: String, completeHandler: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        completeHandler?()
    }
    alertController.addAction(okAction)
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
        rootVC.present(alertController, animated: true, completion: nil)
    }
}

func showAlertCompelete(title:String, message: String, settingUrl: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let settingAction = UIAlertAction(title: "Setting", style: .cancel) { (_) -> Void in
        guard let settingsUrl = URL(string: settingUrl) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
    }
    alertController.addAction(okAction)
    alertController.addAction(settingAction)
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
        rootVC.present(alertController, animated: true, completion: nil)
    }
}








