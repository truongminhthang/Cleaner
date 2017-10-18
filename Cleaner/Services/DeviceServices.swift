//
//  DeviceServices.swift
//  disk
//
//  Created by Quốc Đạt on 29.09.17.
//  Copyright © 2017 QuocDat. All rights reserved.
//

import Foundation

class DeviceServices {
   static let shared : DeviceServices = DeviceServices()
    var diskFreePercent: Double {
        return self.diskFree / self.totalSize * 100
    }
    var diskUsedPercent: Double {
        return 100 - self.diskFreePercent
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
    
    var memoryFreePercent :Double {
        return memoryFreeSize/Memory.systemUsage().total * 100
    }
    
    var memoryUsedPercent:Double {
        return memoryUsedSize/Memory.systemUsage().total * 100
    }
    
    
    var memoryFreeSize: Double {
        return (Memory.systemUsage().free + Memory.systemUsage().inactive)
    }
    var memoryUsedSize: Double {
        return (Memory.systemUsage().active + Memory.systemUsage().compressed + Memory.systemUsage().wired)
    }
    var cpuUsedSize:Double {
        return CPU.applicationUsage()
    }
   
}
