//
//  ViewControllerHelper.swift
//  Cleaner
//
//  Created by Quốc Đạt on 10.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import SystemConfiguration

func isConnectionAvailable() -> Bool {
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
    //    if !(isReachable && !needsConnection) {
    //        showAlert(title: "Warning", message: "The Internet is not available")
    //    }
    return isReachable && !needsConnection
}


func showAlertToDeleteApp(title:String, message: String) {
    showAlertCompelete(title: title, message: message, settingUrl: "App-prefs:root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE")
}
func showAlertToAccessAppFolder( title:String, message: String) {
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
    let settingAction = UIAlertAction(title: "Setting", style: .default) { (_) -> Void in
        guard let settingsUrl = URL(string: settingUrl) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
    }
    alertController.addAction(settingAction)
    alertController.addAction(okAction)
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
        rootVC.present(alertController, animated: true, completion: nil)
    }
}






class ActivityIndicator : UIView {

    static var shared : ActivityIndicator! = {
        if let viewArray  =  Bundle.main.loadNibNamed("ActivityIndicator", owner: nil, options: nil) {
            for item in viewArray {
                if item is ActivityIndicator {
                    return item as! ActivityIndicator
                }
            }
        }

        return nil
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let window = AppDelegate.shared.window else {return}
        self.frame = CGRect(x: 0, y: 64, width: window.bounds.width, height: window.bounds.height - 64)
        window.addSubview(self)
        self.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
    }
    
    func showActivity() {
        DispatchQueue.main.async {
            self.isHidden = false
        }
    }
    
    func hideActivity() {
        DispatchQueue.main.async {
            self.isHidden = true

            
        }
    }

}


