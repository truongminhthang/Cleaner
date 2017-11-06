//
//  SystemServices.swift
//  Cleaner
//
//  Created by ChungTran on 10/19/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

struct Usage {
    var free: Double = 0
    var used: Double {
        return total - free
    }
    var total: Double = 0
    var freePercent: Double {
        return (free / total * 100).rounded(toPlaces: 2)
    }
    var usedPercent: Double {
        return 100 - freePercent
    }
}

class SystemServices {
    static let shared : SystemServices = SystemServices()
    var memory = Usage()
    var diskSpace = Usage()
    init() {
       updateAll()
    }
    func updateAll() {
        updateMemoryUsage()
        diskSpaceUsage()
    }
    // MARK: CPU
    var cpuUsage: Double {
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

        var totalUsageOfCPU = 0.0
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
                totalUsageOfCPU  = (totalUsageOfCPU + Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0).rounded(toPlaces: 2)
            }
        }
        return totalUsageOfCPU
    }
    
    // MARK: Memory
    func updateMemoryUsage() {
        let PAGE_SIZE : Double = Double(vm_kernel_page_size)
        memory.total = Double(ProcessInfo.processInfo.physicalMemory)
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
        let inactive = Double(hostInfo.inactive_count) * PAGE_SIZE
        memory.free = free + inactive
    }
    
    // MARK: Disk Space

    func diskSpaceUsage() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard  let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) else {
            return
                print("Error Obtaining System Memory Info:")
            
        }
        if let totalSize = dictionary[FileAttributeKey.systemSize] as? NSNumber {
            diskSpace.total = totalSize.doubleValue
        }
        if let freeSize = dictionary[FileAttributeKey.systemFreeSize] as? NSNumber {
            diskSpace.free = freeSize.doubleValue
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Double) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

