//
//  ArrayExtension.swift
//  Cleaner
//
//  Created by Truong Thang on 11/1/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) -> Int? {
        if let index = index(of: object) {
            remove(at: index)
            return index
        }
        return nil
    }
}
