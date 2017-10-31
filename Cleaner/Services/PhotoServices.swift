//
//  PhotoServices.swift
//  Cleaner
//
//  Created by Truong Thang on 10/31/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Photos

class PhotoServices : NSObject {
    static let shared : PhotoServices = PhotoServices()
    fileprivate let concurrentCleanerAssetQueue =
        DispatchQueue(
            label: "com.bababibo.CleanerAsset.cleanerAssetQueue",
            attributes: .concurrent)
    fileprivate var fetchResult : PHFetchResult<PHAsset>?
    private var _displayedAssets : [CleanerAsset] = []
    
    var displayedAssets : [CleanerAsset] {
        var displayedAssetsCopy : [CleanerAsset]!
        concurrentCleanerAssetQueue.sync {
            displayedAssetsCopy = self._displayedAssets
        }
        return displayedAssetsCopy
    }
    
    func addCleanerAsset(_ cleanerAsset : CleanerAsset) {
        concurrentCleanerAssetQueue.async(flags: .barrier) {
            self._displayedAssets.append(cleanerAsset)
        }
    }
    
    override init() {
        super.init()
        reqestAuthorization()
    }
    
    func reqestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [unowned self] (status) in
            switch status {
            case .authorized:
               self.fetchAsset()
            case .denied:
                fallthrough
            case .notDetermined:
                fallthrough
            case .restricted:
                showAlertToAccessAppFolder(title: "No Photo Permissions", message: "Please grant photo permissions in Settings")
            }
        }
    }
    
    
    func fetchAsset() {
        //    PHPhotoLibrary.shared().register(self)
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        updateDisplayedAssets()
    }
    
    func updateDisplayedAssets() {
        guard let count = fetchResult?.count, count > 0 else { return }
        showActivity()
        let downloadGroup = DispatchGroup()
        
        for index in 0 ..< count {
            downloadGroup.enter()
            _displayedAssets.append(CleanerAsset(asset: fetchResult!.object(at: index), completeBlock: {
                downloadGroup.leave()
            }))
        }
        downloadGroup.notify(queue: DispatchQueue.main) {
            self._displayedAssets = self._displayedAssets.sorted(by: {$0.fileSize > $1.fileSize})
            NotificationCenter.default.post(name: NotificationName.didFinishFetchPHAsset, object: nil)
            hideActivity()
        }
    }
}

