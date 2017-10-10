//
//  DataServices.swift
//  disk
//
//  Created by Quốc Đạt on 28.09.17.
//  Copyright © 2017 QuocDat. All rights reserved.
//

import Foundation
import UIKit
import Photos
import os.log


class DataServices {
    static let shared: DataServices = DataServices()
    
    private var _imageArray: [(image:UIImage, size: Double, type: String)]?
    
    var imageArray: [(image:UIImage, size: Double, type: String)] {
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
        
        
    }
    
    func fetchPhoto() {
        let requestOption : PHImageRequestOptions = {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            return requestOptions
        }()
        
        let fetchOption: PHFetchOptions = {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors =  [NSSortDescriptor(key: "creationDate", ascending: false)]
            return fetchOptions
        }()
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: fetchOption)
        guard fetchResult.count > 0 else {
            print("You have no Photos !")
            return
        }
        _imageArray = Array(repeating:(image:UIImage(), size: 0.0, type: ""), count: fetchResult.count)
        let assetArray = fetchResult.objects(at: IndexSet(0...(fetchResult.count - 1)))
        DispatchQueue.global(qos: .utility).async {
            for (index, asset) in assetArray.enumerated() {
                    PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 90, height: 90), contentMode:.aspectFill, options: requestOption, resultHandler: { (image, dictionary) in
                        
                        guard let aImage = image, dictionary != nil else {
                            return
                        }
                        self._imageArray?[index].image = aImage
                        if asset.duration == 0 {
                            PHCachingImageManager.default().requestImageData(for: asset, options: requestOption, resultHandler: { (data, string, orientation, dictionary) in
                                guard data != nil else {
                                    return
                                }
                                self._imageArray?[index].size =  Double(data!.count)
                                self._imageArray?[index].type = "image"
                            })
                        } else {
                            let videoRequestOptions = PHVideoRequestOptions()
                            videoRequestOptions.version = .original
                            PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: videoRequestOptions, resultHandler: { (avasset, audioMix, diction) in
                                if let url = (avasset as? AVURLAsset)?.url {
                                    if let size = url.fileSize {
                                        self._imageArray?[index].size =  Double(size)
                                    }
                                    self._imageArray?[index].type = "video"
                                    
                                }
                            })
                        }
                    })
               
            }
            
            DispatchQueue.main.async {
                self._imageArray?.sort(by: {$0.size > $1.size})
                NotificationCenter.default.post(name: NSNotification.Name.init("imageArrayUpdate"), object: nil)
            }
        }
       
        NotificationCenter.default.post(name: NSNotification.Name.init("imageArrayUpdate"), object: nil)

        
    }
    //    func fetchVideos() {
    //        let requestOption : PHImageRequestOptions = {
    //            let requestOptions = PHImageRequestOptions()
    //            requestOptions.isSynchronous = true
    //            requestOptions.deliveryMode = .highQualityFormat
    //            return requestOptions
    //        }()
    //
    //        let fetchOption: PHFetchOptions = {
    //            let fetchOptions = PHFetchOptions()
    //            fetchOptions.sortDescriptors =  [NSSortDescriptor(key: "creationDate", ascending: false)]
    //            return fetchOptions
    //        }()
    //
    //        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .video , options: fetchOption)
    //        guard fetchResult.count > 0 else {
    //            print("You have no Video !")
    //            return
    //        }
    //
    //        _videosArray = Array(repeating:(image:UIImage(), size: 0.0), count: fetchResult.count)
    //        let assetArray = fetchResult.objects(at: IndexSet(0...(fetchResult.count - 1)))
    //        for (index, asset) in assetArray.enumerated() {
    //            PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 90, height: 90), contentMode:.aspectFill, options: requestOption, resultHandler: { (image,  dictionary) in
    //
    //                guard let avideo = image, dictionary != nil else {
    //                    return
    //                }
    //           //     self._imageArray?[index].image = avideo
    //                self._videosArray?[index].image = avideo
    //
    //            })
    //
    //            PHCachingImageManager.default().requestImageData(for: asset, options: requestOption, resultHandler: { (data, string, orientation, dictionary) in
    //                guard data != nil else {
    //                    return
    //                }
    //                self._videosArray?[index].size = Double(data!.count)
    //
    //
    //            })
    //        }
    //
    //        _videosArray?.sort(by: {$0.size > $1.size})
    //        NotificationCenter.default.post(name: NSNotification.Name.init("imageArrayUpdate"), object: nil)
    //    }
    
}


