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
  
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    
}


