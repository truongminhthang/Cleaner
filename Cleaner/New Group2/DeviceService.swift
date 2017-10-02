//
//  DeviceService.swift
//  disk
//
//  Created by Quốc Đạt on 29.09.17.
//  Copyright © 2017 QuocDat. All rights reserved.
//

import Foundation
class DeviceService {
    var freePercent: Double {
        return self.diskFree / self.totalSize * 100
    }
    
    var totalSize: Double  {
        let totalSize: Double = 0
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
            if let freeSize = dictionary[FileAttributeKey.systemSize] as? NSNumber {
                return freeSize.doubleValue
            }
        }   else{
            print("Error Obtaining System Memory Info:")
        }
       return totalSize
    }
    var diskFree: Double {
        let totaldisk:Double = 0
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
            if let freeSize = dictionary[FileAttributeKey.systemFreeSize] as? NSNumber {
                return freeSize.doubleValue
            }
        }else{
            print("Error Obtaining System Memory Info:")
        }
      return totaldisk
    }
  
    
   
}
