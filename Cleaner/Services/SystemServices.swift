//
//  SystemServices.swift
//  Cleaner
//
//  Created by ChungTran on 10/19/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

typealias MemoryState = (memoryFree: Double, memoryUsed: Double, totalMemory: Double)

class SystemServices {
    static let shared: SystemServices = SystemServices()
    
    // MARK: CPU
    func cpuUsage() -> Double {
        let basicInfoCount = MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size
        
        var kern: kern_return_t
        
        var threadList = UnsafeMutablePointer<thread_act_t>.allocate(capacity: 1)
        var threadCount = mach_msg_type_number_t(basicInfoCount)
        
        var threadInfo = thread_basic_info.init()
        var threadInfoCount: mach_msg_type_number_t
        
        var threadBasicInfo: thread_basic_info
        var threadStatistic: UInt32 = 0
        
        kern = withUnsafeMutablePointer(to: &threadList) {
            #if swift(>=3.1)
                return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                    task_threads(mach_task_self_, $0, &threadCount)
                }
            #else
                return $0.withMemoryRebound(to: (thread_act_array_t?.self)!, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadCount)
                }
            #endif
        }
        if kern != KERN_SUCCESS {
            return -1
        }
        
        if threadCount > 0 {
            threadStatistic += threadCount
        }
        
        var totalUsageOfCPU: Double = 0.0
        
        for i in 0..<threadCount {
            threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            kern = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threadList[Int(i)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }
            if kern != KERN_SUCCESS {
                return -1
            }
            
            threadBasicInfo = threadInfo as thread_basic_info
            
            if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                totalUsageOfCPU = (totalUsageOfCPU + Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0).rounded(toPlaces: 2)
            }
        }
        
        return totalUsageOfCPU
    }
    
    // MARK: Memory
    var memoryState : MemoryState = (0,0,0)
    func updateMemoryUsage() {
        let PAGE_SIZE : Double = Double(vm_kernel_page_size)
        let totalMemory: Double = Double(ProcessInfo.processInfo.physicalMemory)
        let hostInfo: vm_statistics64 = {
                var size: mach_msg_type_number_t = UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
                var hostInfo = vm_statistics64()
                
                let result = withUnsafeMutablePointer(to: &hostInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                        host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
                    }
                }
                #if DEBUG
                    if result != KERN_SUCCESS {
                        print("ERROR - \(#file):\(#function) - kern_result_t = "
                            + "\(result)")
                    }
                #endif
                return hostInfo
        }()
        
        let free = Double(hostInfo.free_count) * PAGE_SIZE
        let active = Double(hostInfo.active_count) * PAGE_SIZE
        let inactive = Double(hostInfo.inactive_count) * PAGE_SIZE
        let wired = Double(hostInfo.wire_count) * PAGE_SIZE
        let compressed = Double(hostInfo.compressor_page_count) * PAGE_SIZE
        let memoryUsed = active + compressed + wired
        let memoryFree = free + inactive
        memoryState = (memoryFree, memoryUsed, totalMemory)
    }

    // MARK: Disk Space
    func diskSpaceUsage(inPercent: Bool) -> (diskSpace: Double, useDiskSpace: Double, freeDiskSpace: Double) {
        var totalUseDiskSpace: Double = 0.0
        var totalFreeDisk: Double = 0.0
        var totaldiskSpace: Double  {
            let totaldiskSpace: Double = 0
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
                if let freeSize = dictionary[FileAttributeKey.systemSize] as? NSNumber {
                    return freeSize.doubleValue
                }
            }   else{
                print("Error Obtaining System Memory Info:")
            }
            return totaldiskSpace
        }
        var totalFreeDiskSpace: Double {
            let totalFreeDiskSpace:Double = 0
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
                if let freeSize = dictionary[FileAttributeKey.systemFreeSize] as? NSNumber {
                    return freeSize.doubleValue
                }
            }else{
                print("Error Obtaining System Memory Info:")
            }
            return totalFreeDiskSpace
        }
        if inPercent {
            totalUseDiskSpace = (totaldiskSpace - totalFreeDiskSpace) * 100 / totaldiskSpace
            totalFreeDisk = 100 - totalUseDiskSpace
        } else {
            totalUseDiskSpace = totaldiskSpace - totalFreeDiskSpace
            totalFreeDisk = totalFreeDiskSpace
        }
        return (totaldiskSpace.rounded(toPlaces: 2), totalUseDiskSpace.rounded(toPlaces: 2), totalFreeDisk.rounded(toPlaces: 2))
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Double) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

