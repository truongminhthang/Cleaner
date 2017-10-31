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

class CleanerAsset {
    var thumbnailStatus: AssetStatus = .fetching
    var fileSizeStatus: AssetStatus = .fetching
    var asset: PHAsset
    var thumbnail: UIImage?
    var fileSize = 0
    var representedAssetIdentifier: String
    
    init(asset: PHAsset, completeBlock: @escaping () -> Void) {
        self.asset = asset
        self.representedAssetIdentifier = asset.localIdentifier
        fetchImage()
        fetchFileSize(completeBlock: completeBlock)
    }
    
    func fetchImage() {
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: thumbnailSize,
                                              contentMode: .aspectFill,
                                              options: nil)
        { image, info in
            if let image = image {
                if self.representedAssetIdentifier == self.asset.localIdentifier {
                    self.thumbnail = image
                    self.thumbnailStatus = .goodToGo
                }
            } else if let info = info,
                let _ = info[PHImageErrorKey] as? NSError {
                self.thumbnailStatus = .failed
            }
        }
    }
    func fetchFileSize(completeBlock:  @escaping () -> Void) {
        asset.getURL { (url) in
            guard url != nil else {
                self.fileSizeStatus = .failed
                return
            }
            self.fileSize = url?.fileSize ?? 0
            self.fileSizeStatus = .goodToGo
            completeBlock()
        }
    }
}
