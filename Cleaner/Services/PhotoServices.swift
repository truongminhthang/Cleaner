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
    var isFetching : Bool = true
    fileprivate let concurrentCleanerAssetQueue =
        DispatchQueue(
            label: "com.bababibo.CleanerAsset.cleanerAssetQueue",
            attributes: .concurrent)
    var fetchResult : PHFetchResult<PHAsset>?
    var isDeleting = false
    private var _displayedAssets : [CleanerAsset] = [] {
        didSet {
            guard !isDeleting else {return}
            NotificationCenter.default.post(name: NotificationName.didFinishFetchPHAsset, object: nil)
        }
    }
   
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
    func insertCleanerAsset(at index: Int) {
        concurrentCleanerAssetQueue.async(flags: .barrier) {
            let cleanerAsset = CleanerAsset(asset: self.fetchResult!.object(at: index))
            self._displayedAssets.insert(cleanerAsset, at: index)
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
    
    
    func fetchAsset() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        updateDisplayedAssets()
    }
    
    func updateDisplayedAssets() {
        guard let count = fetchResult?.count, count > 0 else { return }
        _displayedAssets = []
        let downloadGroup = DispatchGroup()
        for index in 0 ..< count {
            downloadGroup.enter()
            _displayedAssets.append(CleanerAsset(asset: fetchResult!.object(at: index), completeBlock: {
                downloadGroup.leave()
            }))
        }
        downloadGroup.notify(queue: DispatchQueue.main) {
            self._displayedAssets = self._displayedAssets.sorted(by: {$0.fileSize > $1.fileSize})
            self.isFetching = false
            NotificationCenter.default.post(name: NotificationName.didFinishSortedFile, object: nil)
        }
    }
}

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) -> Int? {
        if let index = index(of: object) {
            remove(at: index)
            return index
        }
        return nil
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension PhotoServices : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {

        guard let changes = changeInstance.changeDetails(for: fetchResult!)
            else { return }

        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            if changes.hasIncrementalChanges {
                if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                    fetchAsset()
                }
               
            } else {
              
            }
        }
    }
}




