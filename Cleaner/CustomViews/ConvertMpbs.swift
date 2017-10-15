//
//  ExtensionNetwork.swift
//  Cleaner
//
//  Created by Hao on 10/14/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation
import UIKit

class UnitDataRate: Dimension {
    static let kilobitPerSecond = UnitDataRate(symbol: "kbps", converter: UnitConverterLinear(coefficient: 1))
    static let megabitPerSecond = UnitDataRate(symbol: "Mbps", converter: UnitConverterLinear(coefficient: 1_000))
    static let gigabitPerSecond = UnitDataRate(symbol: "Gbps", converter: UnitConverterLinear(coefficient: 1_000_000))
    override class func baseUnit() -> UnitDataRate {
        return .megabitPerSecond
    }
}


