//
//  UserDefaultServices.swift
//  Cleaner
//
//  Created by Hao on 10/25/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation
import UIKit
class SharedUserDefaults {
    static let shared: SharedUserDefaults = SharedUserDefaults()
//    var number = UserDefaults.standard
//    var numberDefault = UserDefaults.standard.object(forKey: "freeMemory")
    var a = 0 
    
    
    var memoryFreePercentFake: Double {
        return 15.0
    }
    var memoryUsedPercentFake: Double {
        return 85.0
    }
    var memoryFreeFake: Double {
       return memoryFreePercentFake / 100 * SystemServices.shared.memoryUsage(inPercent: false).totalMemory
    }
    var memoryUsedFake: Double {
        return (SystemServices.shared.memoryUsage(inPercent: false).totalMemory - memoryFreeFake)
    }
}

