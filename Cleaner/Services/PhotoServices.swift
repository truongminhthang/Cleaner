//
//  PhotoServices.swift
//  Cleaner
//
//  Created by Truong Thang on 10/31/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Photos

class PhotoServices : NSObject, PHPhotoLibraryChangeObserver {
    var isFetching : Bool = false
    fileprivate let concurrentCleanerAssetQueue =
        DispatchQueue(
            label: "com.bababibo.CleanerAsset.cleanerAssetQueue",
            attributes: .concurrent)
    var fetchResult : PHFetchResult<PHAsset>?
    private var _displayedAssets : [CleanerAsset] = [] {
        didSet {
            guard !isDeleting else {return}
            NotificationCenter.default.post(name: NotificationName.didFinishFetchPHAsset, object: nil)
        }
    }
    
   
    var displayedAssets : [CleanerAsset] {
        get {
            var displayedAssetsCopy : [CleanerAsset]!
            concurrentCleanerAssetQueue.sync {
                displayedAssetsCopy = self._displayedAssets
            }
            return displayedAssetsCopy
        }
        set {
            concurrentCleanerAssetQueue.async(flags: .barrier) {
                self._displayedAssets = newValue
            }
        }
    }
    
    func addCleanerAsset(_ cleanerAsset : CleanerAsset) {
        concurrentCleanerAssetQueue.async(flags: .barrier) {
            self._displayedAssets.append(cleanerAsset)
        }
    }
    
    func removeCleanerAsset(_ cleanerAsset : CleanerAsset, completionHandler: ((Bool, Int, Error?) -> Void)? = nil) {
        concurrentCleanerAssetQueue.async(flags: .barrier) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([cleanerAsset.asset] as NSArray)
                self.isDeleting = true
            }, completionHandler: { (success, error) in
                guard success else {
                    return
                }
                
                if let removeIndex = self._displayedAssets.remove(object: cleanerAsset) {
                    completionHandler?(success, removeIndex, error)
                    self.isDeleting = false
                }
            })
        }
        
    }
    
    override init() {
        super.init()
        reqestAuthorization()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
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
    
    // MARK: Request fetch and update asset
    var shouldShowActivity = true

    func fetchAsset() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        updateDisplayedAssets(fetchResult: fetchResult!)
    }
    
    func updateDisplayedAssets(fetchResult: PHFetchResult<PHAsset>) {
        let count = fetchResult.count
        guard fetchResult.count > 0 else { return }
        guard isFetching == false else {return}
        isFetching = true
        if shouldShowActivity {
            DispatchQueue.main.async {
                ActivityIndicator.shared.showActivity()
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    self.didFinishUpdate()
                }
            }
        }
        self.displayedAssets = []
        let downloadGroup = DispatchGroup()
        for index in 0 ..< count {
            downloadGroup.enter()
            addCleanerAsset(CleanerAsset(asset: fetchResult.object(at: index), completeBlock: {
                downloadGroup.leave()
            }))
        }
        downloadGroup.notify(queue: DispatchQueue.main) {
           self.didFinishUpdate()
        }
    }
    
    func didFinishUpdate() {
        self.displayedAssets = self.displayedAssets.sorted(by: {$0.fileSize > $1.fileSize})
        self.isFetching = false
        self.isRemoving = false
        NotificationCenter.default.post(name: NotificationName.didFinishSortedFile, object: nil)
        ActivityIndicator.shared.hideActivity()
    }
    
    // MARK: - Handle remove and insert in photo libraray
    
    var isDeleting = false
    var isRemoving = false


    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult!)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            if changes.hasIncrementalChanges {
                if let inserted = changes.insertedIndexes, !inserted.isEmpty {

                }
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    if isRemoving {isRemoving = false; return}
                    self.updateDisplayedAssets(fetchResult: changes.fetchResultAfterChanges)
                    
                }
                if let removed = changes.removedIndexes, !removed.isEmpty {
                    isRemoving = true
                }
                
            } else {
                
            }
        }
    }
}





