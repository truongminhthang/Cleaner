//
//  ActivityIndicator.swift
//  Cleaner
//
//  Created by Truong Thang on 11/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class ActivityIndicator : UIView {
    static var shared : ActivityIndicator! = {
        if let viewArray  =  Bundle.main.loadNibNamed("ActivityIndicator", owner: nil, options: nil) {
            for item in viewArray {
                if item is ActivityIndicator {
                    return item as! ActivityIndicator
                }
            }
        }
        return nil
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let window = AppDelegate.shared.window else {return}
        self.frame = CGRect(x: 0, y: 64, width: window.bounds.width, height: window.bounds.height - 64)
        window.addSubview(self)
        self.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
    }
    
    func showActivity() {
        DispatchQueue.main.async {
            self.isHidden = false
        }
    }
    
    func hideActivity() {
        DispatchQueue.main.async {
            self.isHidden = true
        }
    }
}
