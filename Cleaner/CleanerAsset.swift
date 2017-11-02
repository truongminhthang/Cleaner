//
//  CleanerAsset.swift
//  Cleaner
//
//  Created by Truong Thang on 10/31/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Photos

enum AssetStatus {
    case fetching
    case goodToGo
    case failed
}
private let scale = UIScreen.main.scale
private let cellSize = CGSize(width: 64, height: 64)
private let thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)

class CleanerAsset: Equatable {
    var thumbnailStatus: AssetStatus = .fetching
    var fileSizeStatus: AssetStatus = .fetching
    var asset: PHAsset
    var thumbnail: UIImage?
    var fileSize = 0
    var representedAssetIdentifier: String
    var orderPosition: Int?
    var dateCreatedString = ""
    
    init(asset: PHAsset, completeBlock: (() -> Void)? = nil) {
        self.asset = asset
        self.representedAssetIdentifier = asset.localIdentifier
        if let date = self.asset.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM , yyyy"
            dateCreatedString = dateFormatter.string(from:date)
        }
        fetchImage()
        fetchFileSize(completeBlock: completeBlock)
    }
    
    func fetchImage(completeBlock:  (() -> Void)? = nil) {
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: thumbnailSize,
                                              contentMode: .aspectFill,
                                              options: nil)
        { image, info in
            if let image = image {
                if self.representedAssetIdentifier == self.asset.localIdentifier {
                    self.thumbnail = image
                    self.thumbnailStatus = .goodToGo
                    if !PhotoServices.shared.isFetching {
                        NotificationCenter.default.post(name: NotificationName.didFinishFetchPHAsset, object: nil)

                    }
                    completeBlock?()
                }
            } else if let info = info,
                let _ = info[PHImageErrorKey] as? NSError {
                self.thumbnailStatus = .failed
            }
        }
    }
    
    func fetchFileSize(completeBlock:  (() -> Void)?) {
        if asset.duration == 0 {
            PHImageManager.default().requestImageData(for: asset, options: nil, resultHandler: { (data, string, orientation, dictionary) in
                guard data != nil else {return}
                self.fileSize = data?.count ?? 0
                self.fileSizeStatus = .goodToGo
                completeBlock?()
            })
        } else {
            asset.getURL { (url) in
                guard url != nil else {
                    self.fileSizeStatus = .failed
                    return
                }
                self.fileSize = url?.fileSize ?? 0
                self.fileSizeStatus = .goodToGo
                completeBlock?()
            }
        }
    }
    
    func remove(completionHandler: ((Bool, Int, Error?) -> Void)? = nil) {
       
        PhotoServices.shared.removeCleanerAsset(self, completionHandler: completionHandler)
    }
    
    public static func ==(lhs: CleanerAsset, rhs: CleanerAsset) -> Bool {
        return lhs.representedAssetIdentifier == rhs.representedAssetIdentifier


    }

 
}
