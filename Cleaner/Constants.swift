//
//  Constant.swift
//  Cleaner
//
//  Created by Hao on 10/7/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation

struct NotificationName {
    


}


extension Notification.Name {
    static let updateDownloadSpeed = Notification.Name.init("updateDownloadSpeed")
    static let updateUploadSpeed = Notification.Name.init("updateUploadSpeed")
    static let didFinishTestDownload = Notification.Name.init("didFinishTestDownload")
    static let didFinishTestUpload = Notification.Name.init("didFinishTestUpload")
    static let didFinishFetchPHAsset = Notification.Name.init("didFinishFetchPHAsset")
    static let didFinishSortedFile = Notification.Name.init("didFinishSortedFile")
    static let didAddPHAsset = Notification.Name.init("didAddPHAsset")
    static let reloadData = Notification.Name.init("reloadData")
    static let toggleMenu = Notification.Name.init("toggleMenu")
    
}
