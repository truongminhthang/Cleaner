//
//  ViewControllerHelper.swift
//  Cleaner
//
//  Created by Quốc Đạt on 10.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import SystemConfiguration

func showAlert(vc: UIViewController?, title:String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        GoogleAdMob.sharedInstance.showInterstitial()
    }
    alertController.addAction(okAction)
    vc?.present(alertController, animated: true, completion: nil)
}
func isConnectionAvailable(vc: UIViewController? = nil) -> Bool {
    var zero_Address = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0,0,0,0,0,0,0,0 ))
    zero_Address.sin_len = UInt8(MemoryLayout.size(ofValue: zero_Address))
    zero_Address.sin_family = sa_family_t(AF_INET)
    let defaulte = withUnsafePointer(to: &zero_Address) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1)
        {
            zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaulte!, &flags) == false {
        return false
    }
    let isReachable = flags == .reachable
    let needsConnection = flags == .connectionRequired
    if !(isReachable && !needsConnection) {
        showAlert(vc: vc,  title: "Warning", message: "The Internet is not available")
    }
    return isReachable && !needsConnection
}

func showAlertCompelete(vc: UIViewController, title:String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let goToStorageBackup = UIAlertAction(title: "Setting", style: .default) { (_) -> Void in
        guard let settingsUrl = URL(string: "App-prefs:root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE") else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        GoogleAdMob.sharedInstance.showInterstitial()
    }
    alertController.addAction(goToStorageBackup)
    alertController.addAction(okAction)
    vc.present(alertController, animated: true, completion: nil)
}
 
