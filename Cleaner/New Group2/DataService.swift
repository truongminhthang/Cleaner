//
//  DataService.swift
//  disk
//
//  Created by Quốc Đạt on 28.09.17.
//  Copyright © 2017 QuocDat. All rights reserved.
//

import Foundation
import UIKit
import Photos
import os.log


class DataService {
    static let shared: DataService = DataService()
    
    var requestOption : PHImageRequestOptions = {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }()
    
    var fetchOption: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors =  [NSSortDescriptor(key: "creationDate", ascending: true)]
        return fetchOptions
    }()

    
    private var _imageArray: [UIImage]?
    
    var imageArray: [UIImage] {
        set {
            _imageArray = newValue
        }
        get {
            if _imageArray == nil {
                updateImageArray()
            }
            return _imageArray ?? []
        }
    }
    
    func updateImageArray() {
        
        _imageArray = []
        fetchPhoto()
        NotificationCenter.default.post(name: NSNotification.Name.init("imageArrayUpdate"), object: nil)
    }
    
    var imageSize = [Double]()
    
    func fetchPhoto() {
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOption)
        guard fetchResult.count > 0 else {
            print("You have no Photos !")
            return
        }
         let assetArray = fetchResult.objects(at: IndexSet(0...(fetchResult.count - 1)))
        for asset in assetArray {
            PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 90, height: 90), contentMode:.aspectFill, options: requestOption, resultHandler: { (image, dictionary) in
                
                guard let aImage = image, dictionary != nil else {
                    return
                }
                self.imageArray.append(aImage)
             
            })
            PHCachingImageManager.default().requestImageData(for: asset, options: requestOption, resultHandler: { (data, string, orientation, dictionary) in
                guard data != nil else {
                    return
                }
                self.imageSize.append(Double(data!.count))
                
            })
        }
        
    }
}


