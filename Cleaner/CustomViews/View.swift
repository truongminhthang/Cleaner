//
//  Design.swift
//  App1
//
//  Created by Luyen on 9/30/17.
//  Copyright © 2017 Luyen. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class View : UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if cornerRadius == -1 {
            self.layer.cornerRadius = self.bounds.width < self.bounds.height ? self.bounds.width * 0.5 : self.bounds.height * 0.5
        }
    }
}

@IBDesignable
class Button: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if cornerRadius == -1 {
            self.layer.cornerRadius = self.bounds.width < self.bounds.height ? self.bounds.width * 0.5 : self.bounds.height * 0.5
        }
    }
}


fileprivate class Keys {
    static let TOP_BORDER = "top-border"
    static let TOP_BORDER_VIEW = "top-border-view"
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return CGFloat(tag)
        }
        set {
            layer.cornerRadius = newValue
            tag = Int(newValue)
            if newValue == -1 {
                self.clipsToBounds = true
                self.layer.cornerRadius = self.bounds.width < self.bounds.height ? self.bounds.width * 0.5 : self.bounds.height * 0.5
            } else {
                layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var topBorder: Bool {
        get {
            if self.layer.value(forKey: Keys.TOP_BORDER) != nil {
                return self.layer.value(forKey: Keys.TOP_BORDER) as! Bool
            }
            
            return false
        }
        set {
            self.layer.setValue(newValue, forKey: Keys.TOP_BORDER)
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    
}
