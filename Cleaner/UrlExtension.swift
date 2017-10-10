//
//  UrlExtension.swift
//  Cleaner
//
//  Created by Truong Thang on 10/10/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation

// MARK: - <#Mark#>

extension URL {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? self.resourceValues(forKeys: keys)
        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}
